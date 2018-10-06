class Procurements::PurchaseOrders::Template::Create < Procurements::PurchaseOrders::Template::Base
  attr_accessor :purchase_order, :template

  def pre_validate
    user_present? and params_present?
    return if has_errors?
  end

  def init
    result = Procurements::PurchaseOrder::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.purchase_order = result.purchase_order
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
      return
    end
  end

  def process
    result = Template::Create.(user, resource: self.purchase_order)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.template = result.template
  end

  def success
    params[:template] = self.template
    Procurements::PurchaseOrders::Template::Create::SuccessPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::Template::Create::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :template

    def init
      self.template = params[:template]
    end

  end

end