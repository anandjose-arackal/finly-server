class Procurements::PurchaseOrders::Template::Show < Procurements::PurchaseOrders::Template::Base
  attr_accessor :purchase_order

  def pre_validate
    user_present? and params_present?
    return if has_errors?
    if params[:id].blank? and params[:purchase_order_id].blank? and params[:template_id].blank?

    end
  end

  def init
    result = Procurements::PurchaseOrders::Template::Index.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    id = params[:id] || params[:purchase_order_id] || params[:template_id]
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
    Procurements::PurchaseOrders::Template::Show::SuccessPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::Template::Show::SuccessPresenter < BaseOperation::BasePresenter
    attr_accessor :purchase_order, :template

    def init
      self.purchase_order = params[:purchase_order]
      self.template = params[:purchase_order]
    end

  end

end