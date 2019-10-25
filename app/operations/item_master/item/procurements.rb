class ItemMaster::Item::Procurements < ItemMaster::Item::Base
  attr_accessor :documents, :item

  class ItemMaster::Item::Procurements::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :data, :documents, :paginated_documents

    def init
      self.documents = params[:documents]
      page = params[:page] || 1
      per_page = params[:per_page] || 30
      self.paginated_documents = self.documents.paginate(page: page, per_page: per_page)
    end
  end

  def init
    result = ItemMaster::Item::Show.(user, params)

    if result.failure?
      add_message :error, result.messages[:error]
      return
    end
    self.item = result.inventory_item
  end

  def validate
    if self.item.blank?
      add_message :error, "Item Not Found"
      return
    end

    if ["purchase_order", "po_invoice", "non_po_invoice", "purchase_request"].exclude? params[:document_type]
      add_message :error, "Improper request sent to gather document details. Please contact Finly Customer Support."
      return
    end
  end

  def process
    case params[:document_type]
    when 'purchase_order'
      document_ids = PurchaseOrderItem.where(inventory_line_item_id: self.item.id).map(&:purchase_order_id).uniq
      self.documents = user.company.purchase_orders.where(id: document_ids)
    when 'po_invoice'
      document_ids = InvoiceLineItem.where(inventory_line_item_id: self.item.id).map(&:parent_id).uniq
      self.documents = user.company.inward_invoices.with_type_po_invoice.where(id: document_ids)
    when 'non_po_invoice'
      document_ids = InvoiceLineItem.where(inventory_line_item_id: self.item.id).map(&:parent_id).uniq
      self.documents = user.company.inward_invoices.with_type_non_po_invoice.where(id: document_ids)
    when "purchase_request"
      document_ids = PurchaseRequestItem.where(item_id: self.item.id).map(&:purchase_request_id).uniq
      self.documents = user.company.purchase_requests.where(id: document_ids)
    end
  end

  def success
    params[:documents] = self.documents
    ItemMaster::Item::Procurements::SuccessPresenter.new(user, params, messages)
  end
end