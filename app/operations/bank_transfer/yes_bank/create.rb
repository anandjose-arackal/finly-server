# according to the new flow, once the data is here, the payment request will be validated
# and approved through the flow and will be used to create a payment order from the parameters
class BankTransfer::YesBank::Create < BankTransfer::YesBank::Base
  attr_accessor :order_data, :payment_request, :payment_order, :scheduled_at,
                :processed_order_data, :initiating_account,
                :bank_payment_request, :bank_transfer_type

  def pre_validate
    super
    return if has_errors?
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:bank_payment_request].blank?
      add_message :error, 'Error loading request'
      return
    end
  end

  def init
    # self.order_data = params[:payment_order]

    # because now all orders will be through a bank payment request
    self.bank_payment_request = params[:bank_payment_request]
    self.payment_order = bank_payment_request.payment_order
    self.bank_transfer_type = payment_order.bank_transfer_type
    ################################################################

  end

  def validate

  end

  def pre_process
    # updating the state of the payment request, because if it gets here, the status is approved,
    # irrespective of if whether the actual payments succeeded or not
    if self.bank_payment_request.present?
      bank_payment_request.update(status_id: BankPaymentRequestStatus.id_for(:approved))
    end

    # # also set the payment order's status id as either scheduled or as pending
    # if payment_order.scheduled_at.present? && payment_order.scheduled_at > DateUtils.local_date
    #   payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:scheduled))
    #   payment_order.payments.update_all(payment_status_id: PaymentStatus.id_for(:scheduled))
    # else
    #   payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:pending))
    #   payment_order.payments.update_all(payment_status_id: PaymentStatus.id_for(:pending))
    # end
  end

  def process

    # calling the payment processor to complete the transfer using adapters
    op = AccountManager::Payments::PaymentProcessor.(user, {payment_order: bank_payment_request&.payment_order, bank_transfer_type: self.bank_transfer_type, background: true})
    unless op.success?

      add_message :error, op.messages[:error]
      payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:failed))
      payment_order.payments.update_all(payment_status_id: PaymentStatus.id_for(:pending))
      payment_order.payments.each do |payment|
        payment.system_messages.create(content: op.messages[:error].to_sentence,
                                       system_message_type_id: SystemMessageType.id_for(:error))
      end
      return
    end
    self.payment_order = op.payment_order
  end

  def post_process
    add_message :success, "Transfers scheduled successfully!"
  end

  def success
    params[:payment_order] = self.payment_order
    BankTransfer::YesBank::Create::SuccessPresenter.new(user, params, messages)
  end

  def failure
    params[:payment_order] = self.payment_order
    BankTransfer::YesBank::Create::FailurePresenter.new(user, params, messages)
  end

  class BankTransfer::YesBank::Create::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_order

    def init
      self.payment_order = params[:payment_order]
    end

  end

  class BankTransfer::YesBank::Create::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :payment_order

    def init
      self.payment_order = params[:payment_order]
    end

  end

end

