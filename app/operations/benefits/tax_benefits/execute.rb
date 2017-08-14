# Execute executes the payment order and is always executed in the background.
# It can only be executed directly from create or from crono
class Benefits::TaxBenefits::Execute < BackgroundOperation
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
    AccountManager::Payments::PaymentOrderExecutor.(payment_order)
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
