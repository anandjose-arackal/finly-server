class Benefits::TaxBenefits::Index < Benefits::TaxBenefits::Base
  attr_accessor :payment_orders

  def pre_validate
    super
    return if has_errors?
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank?
      add_message :error, 'Error loading configuration'
      return
    end
  end

  def init
    # self.payment_orders = user.company.payment_orders.with_type_id(payment_order_type_id)
    self.payment_orders = user.company.payment_orders
  end

  def success
    params[:payment_orders] = self.payment_orders
    Benefits::TaxBenefits::Index::SuccessPresenter.new(user, params, messages)
  end

  class Benefits::TaxBenefits::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_orders
    include HasScope

    has_scope :with_application

    def init
      self.payment_orders = params[:payment_orders]
      self.payment_orders = apply_scopes(payment_orders, params)
    end
  end

end