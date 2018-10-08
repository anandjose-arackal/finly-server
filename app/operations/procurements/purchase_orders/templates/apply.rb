class Procurements::PurchaseOrders::Templates::Apply < Procurements::PurchaseOrders::Templates::Base
  attr_accessor :template, :purchase_order, :updated_purchase_order

  def init
    po_result = Procurements::PurchaseOrders::Show.(user, params)
    unless po_result.success?
      add_message :error, po_result.messages[:error]
      return
    end
    self.purchase_order = po_result.purchase_order
    template_result = Procurements::PurchaseOrders::Templates::Show.(user, params)
    unless template_result.success?
      add_message :error, template_result.messages[:error]
      return
    end
    self.template = template_result.template
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
      return
    end
    unless self.template.present?
      add_message :error, 'Template not found'
      return
    end
  end

  def process
    result = Template::Apply.(user, template: self.template, resource: self.purchase_order)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.purchase_order = result.resource
  end

  def success
    params[:purchase_order] = self.purchase_order
    params[:template] = self.template
    Procurements::PurchaseOrders::Templates::Apply::SuccessPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::Templates::Apply::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_order, :template

    def init
      self.purchase_order = params[:purchase_order]
      self.template = params[:template]
    end

  end

end