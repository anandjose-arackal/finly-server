class Settlement::SMoneyRequests::Processing::Cancel < Settlement::SMoneyRequests::Processing::Base
  attr_accessor :money_request_processor, :pending_mappings

  def authorized_user_types
    [:admin, :finance_manager]
  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:money_request_processor_id).present?
      add_message :error, 'Batch not found'
      return
    end
    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid Password'
      return
    end
  end

  def init
    groups_presenter = Settlement::SMoneyRequests::Processing::Index.(user, params)
    unless groups_presenter.success?
      add_message :error, groups_presenter.messages[:error]
      return
    end
    self.money_request_processor = groups_presenter.money_request_processors.find_by_id(params[:money_request_processor_id])
  end

  def validate
    unless money_request_processor.present?
      add_message :error, 'Batch not found'
      return
    end

    unless MoneyRequestProcessorStatus.ids_for([:pending, :scheduled, :failed, :partially_completed]).include?(self.money_request_processor.status_id)
      add_message :error, 'Batch cannot be cancelled at this stage'
      return
    end

    # i.e. if the report is being settled via Finly, only if the order is either pending, or failed can it be cancelled
    # in_progress will not come in here because if it's being processed, we cannot cancel it halfway
    if self.money_request_processor.process_via_finly?
      unless [PaymentOrderStatus.id_for(:pending), PaymentOrderStatus.id_for(:failed)].include?(self.money_request_processor.payment_order&.payment_order_status_id)
        add_message :error, 'Batch cannot be cancelled at this stage'
        return
      end
    end
  end

  def pre_process    
    # new feature - in a batch, user can choose which items to cancel individually
    if params[:request_ids].present?
      self.pending_mappings = self.money_request_processor.mappings.not_completed.where id: params[:request_ids]
    else
      self.pending_mappings = self.money_request_processor.mappings.not_completed
    end

    if params[:request_ids].present? && self.pending_mappings.blank?
      add_message :error, "Request details not sent or found."
      return
    end
  end

  def process
    if self.money_request_processor.process_via_finly?
      payment_order = self.money_request_processor.payment_order
      if payment_order.present? and (payment_order.pending? or payment_order.scheduled? or payment_order.in_progress?)
        payment_ids = self.pending_mappings.pluck(:payment_ids) rescue []
        result = AccountManager::Payments::CancelPaymentOrder.(user, payment_order: payment_order, payment_ids: payment_ids)
        unless result.success?
          add_message :error, result.messages[:error]
          return
        end
      end
    end

    # new feature - in a batch, user can choose which items to cancel individually
    # pending_mappings = self.money_request_processor.mappings.not_completed
    pending_mappings_id = self.pending_mappings.pluck(:id)
    ::MoneyRequest.with_processor_mapping(pending_mappings_id).update_all(money_request_processor_mapping_id: nil)
    self.pending_mappings.update_all(status_id: MoneyRequestProcessorStatus.id_for(:cancelled))
    if money_request_processor.partially_completed?
      self.money_request_processor.update(status_id: MoneyRequestProcessorStatus.id_for(:completed))
    elsif self.money_request_processor.mappings.not_completed.present?
      # dont do anything for now
    else
      self.money_request_processor.update(status_id: MoneyRequestProcessorStatus.id_for(:cancelled))
    end
  end

  def post_process
    add_message :success, 'Cancelled Successfully'
  end

end