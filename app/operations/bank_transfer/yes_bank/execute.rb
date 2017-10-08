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
    unless self.payment_order.scheduled?
      add_message :error, "Cannot be processed yet"
    end
  end

  def process
    # this will simply pass the payment order to the PaymentOrderExecutor and it will run the respective
    # operations needed to schedule it
    AccountManager::Payments::PaymentOrderExecutor.(payment_order, bank_transfer_type: self.payment_order.bank_transfer_type)

  end

  def post_process
    # add condition here that if the payment order has been successfully executed,
    # mark the respective bank payment request also as credited
    if payment_order.completed?
      payment_order.bank_payment_request.update(status_id: BankPaymentRequestStatus.id_for(:credited))
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