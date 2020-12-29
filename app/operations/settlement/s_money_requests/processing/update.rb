# Update UTR and Paid status individually for the iten from the Batch show page
# If no details are supplied then money requests are not credited.
# To credit it explicitly, call the mark_as_paid operation
#  
class Settlement::SMoneyRequests::Processing::Update < Settlement::SMoneyRequests::Processing::Base
  attr_accessor :money_request_processor, :mapping, :pending_mappings, :request_params

  def authorized_user_types
    [:admin, :finance_manager]
  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless params.dig(:money_request_processor_mapping, :batch_id).present?
      add_message :error, 'Batch not found'
      return
    end
    if params[:id].blank?
      add_message :error, "Request details not sent"
      return
    end
  end

  def init
    groups_presenter = Settlement::SMoneyRequests::Processing::Index.(user, params)
    unless groups_presenter.success?
      add_message :error, groups_presenter.messages[:error]
      return
    end
    self.money_request_processor = groups_presenter.money_request_processors.find_by_id(params.dig(:money_request_processor_mapping, :batch_id))
    unless money_request_processor.present?
      add_message :error, 'Batch not found'
      return
    end
    
    self.mapping = self.money_request_processor.mappings.find_by id: params[:id]
    self.pending_mappings = self.money_request_processor.mappings.not_completed
    self.request_params = mapping_params
  end

  def validate
    if self.mapping.blank? or self.mapping&.cancelled?
      add_message :error, "Request details not found."
      return
    end
  end

  def pre_process
    params[:money_request_processor_mapping].delete(:batch_id)

    if request_params[:money_requests_attributes].present?

      # [ {id: 1, bank_reference_number: "utr", source_account: "source_account"}, {...}, ... ]
      request_params[:money_requests_attributes].each do |brn|
        unless validate_utr brn[:bank_reference_number]
          add_message :error, "UTR is only allowed to be alphanumberic."
          return
        end

        unless validate_utr brn[:source_account]
          add_message :error, "Source Account is only allowed to be alphanumberic."
          return
        end
      end

      self.mapping.money_requests.each do |money_request|
        details = request_params[:money_requests_attributes].find {|brn| brn if brn[:id].to_i == money_request.id}
        money_request.bank_reference_number = details[:bank_reference_number]&.strip if money_request.bank_reference_number != details[:bank_reference_number]&.strip
        money_request.source_account = details[:source_account]&.strip if money_request.source_account != details[:source_account]&.strip
      end

      params[:money_request_processor_mapping].delete(:money_requests_attributes)

      # if utr is there, we automatically assume the item can be marked as completed
      # request_params[:marked_as_completed] = true
    end

    request_params[:marked_as_completed] = !!StringUtils.to_bool(request_params[:marked_as_completed])
    
    # flag to make sure, we dont create tracks again if item is already marked completed even if spurious request comes from FE
    request_params[:marked_as_completed] = (self.mapping.completed?) ? false : request_params[:marked_as_completed] 

    if request_params[:marked_as_completed]
      request_params[:status_id] = MoneyRequestProcessorStatus.id_for(:completed)
      request_params[:completed_at] = DateTime.now
    end
  end

  def process
    self.mapping.assign_attributes(request_params)

    if self.mapping.valid?
      self.mapping.save      
      update_status
      update_mapping_data if request_params[:marked_as_completed] # only update mr and its tracks if mapping is not completed
    else
      add_message :error, self.mapping.errors.full_messages
      return
    end

    if self.money_request_processor.completed?
      params[:redirect] = true
    else
      params[:redirect] = false
    end

    #adding  money user pocket: if user individually marking as completed
    add_source_pocket(mapping) if request_params[:marked_as_completed]
  end

  def post_process
    add_message :success, 'Updated Successfully'
    # if self.pending_mappings.blank?
    #   add_message :success, "All items credited. Batch status now set to Completed."
    # end
  end

  def success
    Settlement::SMoneyRequests::Processing::Update::SuccessPresenter.new(user, params, messages)
  end

  class Settlement::SMoneyRequests::Processing::Update::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :redirect

    def init
      # Helps to know in frontend if they should redirect to settlement index or simply re-render the same settlement show page
      self.redirect = params[:redirect]
    end
  end

  private

  def mapping_params
    params.require(:money_request_processor_mapping).permit(:bank_reference_number, :marked_as_completed, :completed_at, :status_id, money_requests_attributes: [:bank_reference_number, :source_account, :id])
  end

  def update_mapping_data
    request_status = MoneyRequestStatus.id_for(:credited)
    request_tracking_status = MoneyRequestTrackingAction.id_for(:credited)

    # self.mapping.money_requests.update_all(controlling_user_id: nil, controlling_user_role_id: nil,
    #                                       controlling_for_user_id: nil, controlling_for_user_role_id: nil,
    #                                       status_id: request_status, payment_id: self.mapping.payment&.id)
    money_request_ids = []
    self.mapping.money_requests.each do |money_request|
      next if (money_request.bank_reference_number.blank? and money_request.source_account.blank?)
      money_request_ids << money_request.id
      money_request.tracks.create action_user_id: self.money_request_processor.created_by_user_id,
                                  action_user_role_id: self.money_request_processor.created_by_user_role_id,
                                  money_request_tracking_action_id: request_tracking_status,
                                  status_id: request_status,
                                  payment: self.mapping.payment
    end

    self.mapping.money_requests.where(id: money_request_ids).update_all(controlling_user_id: nil, controlling_user_role_id: nil,
                                          controlling_for_user_id: nil, controlling_for_user_role_id: nil,
                                          status_id: request_status, payment_id: self.mapping.payment&.id)

    update_batch # update the batch status to completed or partially_completed if there are no other pending items left in the batch to be credited.
  end

  def update_batch
    completed_status = MoneyRequestProcessorStatus.id_for(:completed)
    partially_complete_status = MoneyRequestProcessorStatus.id_for(:partially_completed)
    self.pending_mappings = self.money_request_processor.mappings.not_completed

    # set_status = (self.pending_mappings.blank?) ? completed_status : partially_complete_status
    set_status = partially_complete_status

    if self.money_request_processor.processed_amount.blank?
      processed_amount = Amount.new(currency_id: Currency.id_for(:INR))
    else
      processed_amount = self.money_request_processor.processed_amount
    end
    processed_amount.value = self.money_request_processor.payment_order&.amount_processed&.value || self.money_request_processor.total_amount&.value

    self.money_request_processor.update(status_id: set_status, completed_at: DateTime.now,
                                          marked_as_completed: false,processed_amount: processed_amount)
  end

  def validate_utr(utr)
    return true if utr.blank?
    ( /\A[a-zA-Z0-9]*\Z/.match(utr) ) ? true : false
  end

  def update_status
    return false if self.mapping.completed?

    data = self.mapping.money_requests.pluck(:bank_reference_number).reject(&:blank?)
    if data.compact.present? and (data.compact.count == self.mapping.money_requests.count)
      status = MoneyRequestProcessorStatus.id_for(:completed)
      self.mapping.update status_id: status
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
    op = AccountManager::Payments::PaymentProcessor.(user, payment_request: payment_request)
    if op.success?
      coh_payment = op.payments.first
      mapping.payment.update(reference_payment_id: coh_payment.id) if mapping.payment.present?
    end
  end

end
