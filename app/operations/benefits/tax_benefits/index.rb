class Benefits::TaxBenefits::Index < Benefits::TaxBenefits::Base
  attr_accessor :payment_orders

  def pre_validate
    super
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank?
      add_message :error, 'Error loading configuration'
      return
    end
  end

  def process
    self.payment_orders = user.company.payment_orders.with_type_id(payment_order_type_id)
  end

  def success
    params[:payment_orders] = self.payment_orders
    Benefits::TaxBenefits::Index::SuccessPresenter.new(user, params, messages)
  end

  class Benefits::TaxBenefits::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_orders

    def init
      self.payment_orders = params[:payment_orders]
    end
  end

end