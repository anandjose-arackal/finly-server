class BankTransfer::YesBank::Execute < BankTransfer::YesBank::Base

  attr_accessor :payment_order

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or (params[:payment_order_id].blank? and params[:id].blank?)
      add_message :error, 'Order not found'
    end
  end

  def init
    id = (params[:payment_order_id] or params[:id])
    self.payment_order = user.company.payment_orders.find_by_id(id)
  end

  def validate
    if self.payment_order.blank?
      add_message :error, 'Order not found'
      return
    end
    # because now this operation can be called by the bulk credit operation as well
    if self.payment_order.api_initiated
      # ensure that the payment order is not already executed by any chance
      if self.payment_order.completed? || self.payment_order.partially_completed? || self.payment_order.in_progress?
        return
      end
    else
      unless self.payment_order.scheduled? || self.payment_order.pending?
        add_message :error, "Cannot be processed yet"
        return
      end
    end

    if self.payment_order.bank_payment_request.blank?
      add_message :error, "Invalid payment order, cannot be processed"
      add_system_message :error, self.payment_order, "Invalid payment order, cannot be processed"
      return
    end
  end

  def process
    # this will simply pass the payment order to the PaymentOrderExecutor and it will run the respective
    # operations needed to schedule it
    op = AccountManager::Payments::PaymentOrderExecutor.(payment_order, bank_transfer_type: self.payment_order.bank_transfer_type)
  end

  def post_process
    # mark the respective bank payment request as credited because it has been officially executed
    unless payment_order.bank_payment_request&.status_id == BankPaymentRequestStatus.id_for(:credited)
      payment_order.bank_payment_request&.update(status_id: BankPaymentRequestStatus.id_for(:credited))
      # Missing user payment initiating user information hence doing workflow manager's task manually
      current_level = payment_order.bank_payment_request.level
      if current_level.present?
        # Update current dlrm with action
        current_dlrms_taken_control = document.document_level_reviewer_mappings.with_level_id(current_level.id).where(taken_control: true).first rescue nil

        if current_dlrms_taken_control.present?
          taken_control_user = current_dlrms_taken_control.taken_control_by
          current_dlrms_taken_control.update(action_id: TrailAction.id_for(:credit), action_taken_by_id: taken_control_user&.id)
        else
          current_dlrms = document.document_level_reviewer_mappings.with_level_id(current_level.id)

          if current_dlrms.present?
            current_dlrms.update_all(
              action_id: TrailAction.id_for(:credit),
              action_taken_by_id: current_dlrms.first&.reviewer_id
            ) 
          end
        end

        # Update next dlrms as active false
        current_level_number = current_level.level_number
        dlrms = document.document_level_reviewer_mappings.with_level_number_gt(current_level_number)

        if dlrms.present?
          dlrms.update_all(active: false)
        end
      end
    end
  end

  def success
    params[:payment_order] = self.payment_order
    Benefits::TaxBenefits::Execute::SuccessPresenter.new(user, params, messages)
  end

  class Benefits::TaxBenefits::Execute::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_order

    def init
      self.payment_order = params[:payment_order]
    end

  end

end