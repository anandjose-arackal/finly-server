class Procurements::PurchaseOrders::Base < BaseOperation
  attr_accessor :workflow_output
  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
      return
    end
  end

  def purchase_order_parameters
    params.require(:purchase_order).permit(
        :id, :location_id, :delivery_location_id, :procurement_id, :vendor_id, :payment_term_id, :sub_department_id, :cost_center_id,
        :procurement_term_id, :indent_number, :indent_date, :override_po_number, :policy_id, :department_id,
        :billing_address, :shipping_address,
        :delivery_date, :gst_type_id, :inclusive_of_taxes, :roundoff_total_enabled, :roundoff_amount, :procurement_term_text,
        items_attributes: [
            :id, :_destroy, :product_id, :description, :hsn_sac, :quantity, :rate, :tax, :tax_rate_id, :tds, :discount, :delivery_date, :comment,
            :inventory_line_item_id
        ],
        attachments: [],
        document_reviewer_mappings: [
            :level_id, :reviewer_id
        ]
        # tax_amount_attributes: [:value, :currency_id]
    )
  end
end