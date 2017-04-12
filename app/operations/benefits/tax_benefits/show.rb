class Benefits::TaxBenefits::Show < Benefits::TaxBenefits::Base
  attr_accessor :payment_order

  def pre_validate
    super
    return if has_errors?
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:id].blank?
      add_message :error, 'Order not found'
      return
    end
  end

  def init
    self.payment_order = Benefits::TaxBenefits::Index.(config, user, params).payment_orders.with_id(params[:id]).first rescue nil
  end

  def validate
    if self.payment_order.blank?
      add_message :error, 'Order not found'
    end
  end

  def success
    params[:payment_order] = self.payment_order
    Benefits::TaxBenefits::Show::SuccessPresenter.new(user, params, messages)
  end

  class Benefits::TaxBenefits::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_order

    def init
      self.payment_order = params[:payment_order]
    end
  end

end