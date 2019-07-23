class Procurements::InwardDocuments::Base < Procurements::Base

  def pre_validate
    unless user.company.feature_subscription.grn_enabled || user.feature_subscription.srn_enabled
      add_message :error, "Receipt Note not enabled for your company. Please contact your admin or Finly Customer Support."
      return
    end
  end

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