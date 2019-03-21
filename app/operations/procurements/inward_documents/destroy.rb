class Procurements::InwardDocuments::Destroy < Procurements::InwardDocuments::Base
  attr_accessor :inward_document, :procurement, :inward_document_params, :purchase_order, :id_old_attachments,
                :id_current_attachments
  def init
    procurement_id = params[:procurement_id]
    self.procurement = user.company.procurements.find_by id: procurement_id
    inward_document_id = params[:id] || params[:inward_document_id]
    self.inward_document = procurement.inward_documents.find_by id: inward_document_id
    self.inward_document_params = inward_document_parameters
    self.purchase_order = self.procurement&.purchase_order
  end

  def validate
    unless self.inward_document.present?
      add_message :error, 'GRN not found'
      return
    end
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found for this procurement, cannot create GRN'
      return
    end
  end

  def pre_process
    self.id_current_attachments = user.company.procurement_attachments.with_id(inward_document_params[:attachments])

    self.inward_document_params.delete(:attachments)

    self.id_old_attachments = self.inward_document.attachments
  end

  def process
    self.inward_document.assign_attributes(inward_document_params)
    if inward_document.valid?
      # Keep track of delivered items in procurement items
      inward_document.items.each do |item|
        update_purchase_order_item(item)
      end

      # purchase_order.save

      inward_document.save
    else
      add_message :error, inward_document.errors.full_messages
      return
    end

    self.id_old_attachments.update_all(procurement_document_id: nil, procurement_document_type: nil)

    self.id_current_attachments.update_all(procurement_document_id: inward_document.id, procurement_document_type: inward_document.class.name)

  end

  def post_process
    add_message :success, 'Successfully updated GRN'
  end

  private

  def inward_document_parameters
    params.require(:inward_document).permit(:id, :doc_number, :override_doc_number, :delivery_date,
                                            items_attributes: [:id, :delivered, :accepted, :rejected],
                                            attachments: []
    )

  end

  def update_purchase_order_item(item)
    purchase_order_item = self.purchase_order.items.find_by id: item.purchase_order_item_id

    po_item_params = {
        accepted: purchase_order_item.accepted + item.accepted,
        rejected: purchase_order_item.rejected + item.rejected,
        delivered: purchase_order_item.delivered + item.delivered
    }

    purchase_order_item.assign_attributes(po_item_params)
    purchase_order_item.save

  end

end