class Procurements::PurchaseOrders::Templates::Show < Procurements::PurchaseOrders::Templates::Base
  attr_accessor :purchase_order

  def pre_validate
    user_present? and params_present?
    return if has_errors?
    if params[:id].blank? and params[:purchase_order_template_id].blank? and params[:template_id].blank?
      add_message :error, 'Template not found'
      return
    end
  end

  def init
    result = Procurements::PurchaseOrders::Templates::Index.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    id = params[:purchase_order_template_id] || params[:template_id] || params[:id]
    self.purchase_order = result.purchase_orders.find_by(id: id)
  end

  def validate
    if self.purchase_order.blank?
      add_message :error, 'Template not found'
      return
    end
  end

  def success
    params[:purchase_order] = self.purchase_order
    Procurements::PurchaseOrders::Templates::Show::SuccessPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::Templates::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_order, :template

    def init
      self.purchase_order = params[:purchase_order]
      self.template = params[:purchase_order]
    end

  end

end