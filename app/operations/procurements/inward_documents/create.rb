class Procurements::InwardDocuments::Create < Procurements::InwardDocuments::Base
  attr_accessor :inward_document, :procurement, :inward_document_params, :purchase_order
  def init
    procurement_id = params[:procurement_id]
    self.procurement = user.company.procurements.find_by id: procurement_id
    self.inward_document = procurement.inward_documents.find_by id: params[:id]
    self.inward_document_params = inward_document_parameters
    self.purchase_order = self.procurement&.purchase_order
  end

  def validate
    unless self.inward_document.present?
      add_message :error, 'Inward Document not found'
      return
    end
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found for this procurement, cannot create inward document'
      return
    end
  end

  def process
    self.inward_document.assign_attributes(inward_document_params)
    if inward_document.valid?
      inward_document.save
    else
      add_message :error, inward_document.errors.full_messages
    end

  end

  private

  def inward_document_parameters
    params.require(:inward_document).permit(:id, :doc_number, :override_doc_number, :delivery_date,
                                            items_attributes: [:id, :delivered, :accepted, :rejected]
    )

  end

end