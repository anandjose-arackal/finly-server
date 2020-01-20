class Settlement::SMoneyRequests::Processing::PostOperation < FinlyPostOperation
  attr_accessor :payment_order, :money_request_processor, :remaining_mappings, :utr, :pending_mappings, :source_account, :completed_mappings

  def pre_validate
    if object.blank?
      add_message :error, 'Order not found'
      return
    end
  end

  def init
    case object.class.name
      when PaymentOrder.name
        self.payment_order = object
        self.money_request_processor = MoneyRequestProcessor.with_payment_order_id(self.payment_order.id)&.include_mapping_money_requests.first
      when MoneyRequestProcessor.name
        self.money_request_processor = object
      else
        add_message :error, 'Error loading configuration'
        return
    end
  end

  def validate
    if self.money_request_processor.blank?
      add_message :error, 'Order not found'
      return
    end
  end

  def pre_process
    if params[:request_ids].present?
      self.pending_mappings = self.money_request_processor.mappings.not_completed.where id: params[:request_ids]
    else
      self.pending_mappings = self.money_request_processor.mappings.not_completed
    end

    self.completed_mappings = self.money_request_processor.mappings.completed

    if self.pending_mappings.blank?
      add_message :error, "No Money Request found which can be processed."
      return
    end

    self.utr = params[:utr].present? ? params[:utr] : {}
    self.source_account = params[:source_account].present? ? params[:source_account] : {}

    # Since now we can change individual item's status,
    # we check to see if any mappings are remaining to be processed,
    # if so, then we DONT change the entire batch's status
    self.remaining_mappings = self.money_request_processor.mappings.not_completed - self.pending_mappings
  end

  def process
    group_completed_status = MoneyRequestProcessorStatus.id_for(:completed)
    group_failed_status = MoneyRequestProcessorStatus.id_for(:failed)
    group_partially_complete_status = MoneyRequestProcessorStatus.id_for(:partially_completed)
    request_status = MoneyRequestStatus.id_for(:credited)
    request_tracking_status = MoneyRequestTrackingAction.id_for(:credited)
    request_comment_action = MoneyRequestCommentAction.id_for(:credited)

    has_success = false
    has_failure = false

    marked_as_completed = !!params&.dig(:marked_as_completed)
    rejected = self.money_request_processor.rejected?
    update_documents = !!params&.dig(:update_documents)

    if rejected
      request_status = MoneyRequestStatus.id_for(:rejected)
      request_tracking_status = MoneyRequestTrackingAction.id_for(:reject)
      request_comment_action = MoneyRequestCommentAction.id_for(:reject)
    end

    MoneyRequestProcessorMapping.transaction do
      ::MoneyRequest.transaction do
        MoneyRequestTrack.transaction do
          self.pending_mappings.each do |mapping|
            if rejected or marked_as_completed or mapping.payment&.completed? or update_documents
              has_success = true
              # mapping.update(status_id: group_completed_status, completed_at: DateTime.now,
              #                marked_as_completed: marked_as_completed)
              # mapping.money_requests.update_all(controlling_user_id: nil, controlling_user_role_id: nil,
              #                                   controlling_for_user_id: nil, controlling_for_user_role_id: nil,
              #                                   status_id: request_status, payment_id: mapping.payment&.id)

              update_mapping = true
              money_request_ids = []
              mapping.money_requests.each do |money_request|

                money_request.bank_reference_number = self.utr[money_request.id] if self.utr[money_request.id].present?
                money_request.source_account = self.source_account[money_request.id] if self.source_account[money_request.id].present?
                money_request.save if (self.utr[money_request.id].present? or self.source_account[money_request.id].present?)

                # temp workaround for satin a*hles
                # if we do not update the utr or source_account, we dont settle the money_request from update or process template file operation
                # only when the op is called from the mark_as_paid op, we settle the money_requests
                # 

                if update_documents and (money_request.bank_reference_number.blank? or money_request.source_account.blank?)
                  update_mapping = false
                  next
                end

                money_request_ids << money_request.id


                money_request.tracks.create action_user_id: self.money_request_processor.created_by_user_id,
                                            action_user_role_id: self.money_request_processor.created_by_user_role_id,
                                            money_request_tracking_action_id: request_tracking_status,
                                            status_id: request_status,
                                            payment: mapping.payment
                # generate_comment(money_request, mapping, request_comment_action, rejected)
              end

              mapping.money_requests.where(id: money_request_ids).update_all(controlling_user_id: nil, controlling_user_role_id: nil,
                                                controlling_for_user_id: nil, controlling_for_user_role_id: nil,
                                                status_id: request_status, payment_id: mapping.payment&.id)

              if update_mapping
                mapping.update(status_id: group_completed_status, completed_at: DateTime.now,
                             marked_as_completed: marked_as_completed)
              end

              if self.money_request_processor.process_outside_finly? or self.money_request_processor.bank_transfer?
                add_source_pocket(mapping)
              end
            elsif mapping.payment&.failed?
              has_failure = true
              mapping.update(status_id: group_failed_status)
            end
          end
        end
      end
    end

    # explicitly settle money requests of completed mappings when called from batch level
    # 
    update_mapping_data
    # 

    if self.money_request_processor.processed_amount.blank?
      processed_amount = Amount.new(currency_id: Currency.id_for(:INR))
    else
      processed_amount = self.money_request_processor.processed_amount
    end
    processed_amount.value = self.money_request_processor.payment_order&.amount_processed&.value || self.money_request_processor.total_amount.value
    if has_success and has_failure
      self.money_request_processor.update(status_id: group_partially_complete_status, completed_at: DateTime.now,
                                          marked_as_completed: marked_as_completed, processed_amount: processed_amount)
    elsif has_success and self.remaining_mappings.present?
      self.money_request_processor.update(status_id: group_partially_complete_status, completed_at: DateTime.now,
                                          marked_as_completed: marked_as_completed, processed_amount: processed_amount)
    elsif has_success and self.remaining_mappings.blank? and update_documents
      self.money_request_processor.update(status_id: group_partially_complete_status, completed_at: DateTime.now,
                                          marked_as_completed: marked_as_completed, processed_amount: processed_amount)
    elsif has_success and self.remaining_mappings.blank? and not update_documents
      self.money_request_processor.update(status_id: group_completed_status, completed_at: DateTime.now,
                                          marked_as_completed: marked_as_completed,processed_amount: processed_amount)
    elsif has_failure and self.remaining_mappings.blank?
      self.money_request_processor.update(status_id: group_failed_status,processed_amount: processed_amount)
    end
  end

  def add_source_pocket(mapping)
    if money_request_processor.bank_transfer?
      purpose = :advance
    else
      purpose = :advance_outside_finly
    end
    user = mapping.user
    amount = mapping.amount.value
    destination_pocket = mapping.money_requests.first.destination_pocket
    payment_request = PaymentRequest.(user, nil, UserPocket.name, :credit, purpose)
    payment_request.add_payment_item(PaymentRequest::PaymentItem.(user, destination_pocket, amount, reference_resource: mapping.payment))
    AccountManager::Payments::PaymentProcessor.(user, payment_request: payment_request)
  end

  def update_mapping_data
    request_status = MoneyRequestStatus.id_for(:credited)
    request_tracking_status = MoneyRequestTrackingAction.id_for(:credited)

    self.completed_mappings.each do |mapping|
      money_request_ids = []
      mapping.money_requests.each do |money_request|
        next if money_request.credited?  # explicitly settle money request when called from batch level
        money_request_ids << money_request.id
        money_request.tracks.create action_user_id: self.money_request_processor.created_by_user_id,
                                    action_user_role_id: self.money_request_processor.created_by_user_role_id,
                                    money_request_tracking_action_id: request_tracking_status,
                                    status_id: request_status,
                                    payment: mapping.payment
      end

      mapping.money_requests.where(id: money_request_ids).update_all(controlling_user_id: nil, controlling_user_role_id: nil,
                                            controlling_for_user_id: nil, controlling_for_user_role_id: nil,
                                            status_id: request_status, payment_id: mapping.payment&.id)
    end
  end

end