class Procurements::InwardDocuments::Base < Procurements::Base

  def inward_documents_parameters
    # todo change the particulars
    params.permit(:inward_document).require(
        :id, :location_id, :delivery_location_id, :procurement_id, :vendor_id, :payment_term_id,
        items_attributes: [
            :id, :product_id, :description, :quantity, :delivered, :accepted, :rejected
        ],
        attachments: []
    # tax_amount_attributes: [:value, :currency_id]
    )
  end
end