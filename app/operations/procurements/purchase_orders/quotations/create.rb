class Procurements::PurchaseOrders::Quotations::Create < Procurements::PurchaseOrders::Quotations::Base
  attr_accessor :purchase_order, :procurement, :quotation_params, :quotation, :q_old_attachments, :q_current_attachments

  def pre_validate
    Rails.logger.fatal "params for quotation, #{params.inspect}"
    if params[:purchase_order_id].blank?
      add_message :error, "Purchase Order is blank."
      return
    end

    if params[:quotation].blank?
      add_message :error, "Please supply quotation parameters."
      return
    end
  end

  def init
    po_id = params[:purchase_order_id]
    self.quotation_params = quotation_parameters
    self.purchase_order = user.company.purchase_orders.find_by id: po_id
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
      return
    end

    unless self.purchase_order.open? || self.purchase_order.retracted? || self.purchase_order.rejected?
      add_message :error, "Quotations cannot be added if Purchase Order is submitted."
      return
    end

  end

  def pre_process
    self.q_current_attachments = user.company.procurement_attachments.with_id(params[:quotation][:attachments])
    self.quotation_params.delete(:attachments)
  end

  def process
    quotation_params[:purchase_order_id] = self.purchase_order.id
    self.quotation = Quotation.new(quotation_params)

    if quotation.valid?
      quotation.save
      other_quotations = self.purchase_order.quotations.where.not(id: quotation.id)
      other_quotations.update_all(selected: false)

      

      self.q_current_attachments.update_all(procurement_document_id: self.quotation.id, procurement_document_type: self.quotation.class.name)

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
