class BankTransfer::YesBank::Show < BankTransfer::YesBank::Base
  attr_accessor :payment_order, :actions

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
    self.payment_order = BankTransfer::YesBank::Index.(user, params).payment_orders.with_id(params[:id]).first rescue nil
    self.actions = {}
  end

  def validate
    if self.payment_order.blank?
      add_message :error, 'Order not found'
    end

  end

  def process
    # actions[:cancel] = true if self.payment_order.scheduled?
    if payment_order.scheduled?
      actions[:cancel] = Rails.application.routes.url_helpers.bank_transfer_payment_order_path(payment_order)
    end
  end

  def success
    params[:payment_order] = self.payment_order
    params[:actions] = self.actions
    BankTransfer::YesBank::Show::SuccessPresenter.new(user, params, messages)
  end

  class BankTransfer::YesBank::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_order, :actions

    def init
      self.payment_order = params[:payment_order]
      self.actions = params[:actions]
    end
  end

end