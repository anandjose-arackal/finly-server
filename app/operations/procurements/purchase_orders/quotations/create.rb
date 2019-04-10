class Procurements::PurchaseOrders::Quotations::Create < Procurements::PurchaseOrders::Quotations::Base
  attr_accessor :purchase_order, :procurement, :quotation_params, :quotation

  def init
    self.quotation_params = quotation_parameters
    self.purchase_order = user.company.purchase_orders.find_by id: quotation_params[:purchase_order_id]
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
      return
    end

    unless self.purchase_order.open? || self.purchase_order.retracted?
      add_message :error, "Quotations can not be added if Purchase Order is submitted."
      return
    end

  end

  def process
    self.quotation = Quotation.new(quotation_params)

    if quotation.valid?
      quotation.save
      other_quotations = self.purchase_order.quotations.where.not(id: quotation.id)
      other_quotations.update_all(selected: false)
    else
      add_message :error, quotation.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Successfully created quotation'
  end

  def success
    params[:quotation] = self.quotation
    Procurements::PurchaseOrders::QuotationsPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::QuotationsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :quotation

    def init
      self.quotation = params[:quotation]
    end

  end

end
