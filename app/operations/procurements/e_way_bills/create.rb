class Procurements::EWayBills::Create < Procurements::EWayBills::Base
  attr_accessor :inward_document, :procurement, :inward_document_params, :purchase_order
  def init
    procurement_id = params[:procurement_id]
    self.procurement = user.company.procurements.find_by id: procurement_id
    # self.inward_document_params = inward_document_parameters
    self.purchase_order = self.procurement&.purchase_order
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found for this procurement, cannot create inward document'
      return
    end
  end

  def process
    self.inward_document = self.procurement.inward_documents.build()
    inward_document.save

    for item in purchase_order.items
      inward_item_params = inward_document_item_params(item)
      inward_document_item = inward_document.items.build(inward_item_params)
      inward_document_item.save
    end
  end

  def success
    params[:inward_document] = self.inward_document
    Procurements::InwardDocuments::Create::CreatePresenter.new(user, params, messages)
  end

  class Procurements::InwardDocuments::Create::CreatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :inward_document, :items

    def init
      self.inward_document = params[:inward_document]
      self.items = inward_document.items
    end
  end

  private

  def inward_document_item_params(po_item)
    #params
    inward_item_params = {
        purchase_order_item_id: po_item.id,
        inventory_line_item_id: po_item.inventory_line_item_id,
        product_id: po_item.product_id,
        description: po_item.description,
        quantity: po_item.quantity,
        delivered: po_item.delivered,
        accepted: po_item.accepted,
        rejected: po_item.rejected
    }
  end


end

