class Procurements::PurchaseOrders::Base < BaseOperation
  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
      return
    end
  end

  def purchase_order_parameters
    params.require(:purchase_order).permit(
        :id, :location_id, :delivery_location_id, :procurement_id, :vendor_id, :payment_term_id,
        :procurement_term_id, :indent_number, :indent_date, :override_po_number, :po_number,
        :delivery_date, :gst_type_id, :inclusive_of_taxes, :roundoff_total_enabled, :roundoff_amount, :procurement_term_text,
        items_attributes: [
            :id, :_destroy, :product_id, :description, :hsn_sac, :quantity, :rate, :tax, :tds, :discount, :delivery_date, :comment,
            :inventory_line_item_id
        ],
        attachments: []
        # tax_amount_attributes: [:value, :currency_id]
    )
  end
end