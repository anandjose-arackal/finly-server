class BankTransfer::YesBank::Index < BankTransfer::YesBank::Base
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

  def pre_process
    # adding a scope to just include vendor payment parameters
    params[:vendor_payment] = 1
  end

  def success
    params[:payment_orders] = self.payment_orders
    BankTransfer::YesBank::Index::SuccessPresenter.new(user, params, messages)
  end

  class BankTransfer::YesBank::Index::OrdersPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_orders

    include HasScope

    def init
      self.payment_orders = params[:payment_orders]
      self.payment_orders = apply_scopes(payment_orders)
    end
  end


end


