class RetroactivelyAddGstTyeToPoAndInvoice < ActiveRecord::Migration[5.2]
  def change
    change_column :purchase_order_items, :cgst, :decimal, precision: 20, scale: 10
    change_column :purchase_order_items, :sgst, :decimal, precision: 20, range: 10
    change_column :purchase_order_items, :igst, :decimal, precision: 20, range: 10
    change_column :invoice_line_items, :cgst, :decimal, precision: 20, range: 10
    change_column :invoice_line_items, :sgst, :decimal, precision: 20, range: 10
    change_column :invoice_line_items, :igst, :decimal, precision: 20, range: 10

    # this will be run asynchronously as a script
    # PurchaseOrder.all.each do |po|
    #   if po.gst_type_id.present?
    #     next
    #   end
    #   if po.gstin_location.present?
    #     if po.gstin_location.state&.state_code == po.delivery_location&.state&.state_code
    #       po.update(gst_type_id: GstType.id_for(:cgst_sgst))
    #     else
    #       po.update(gst_type_id: GstType.id_for(:igst))
    #     end
    #   else
    #     po.update(gst_type_id: GstType.id_for(:igst))
    #   end
    #   po.update(discount_type_id: 1) if po.discount_type_id.blank?
    # end
    #
    # Invoice.all.find_each(batch_size: 10000) do |invoice|
    #   if invoice.gst_type_id.present?
    #     next
    #   end
    #   if invoice.gstin_location.present?
    #     if invoice.gstin_location.state&.state_code == invoice.delivery_location&.state&.state_code
    #       invoice.update_columns(gst_type_id: GstType.id_for(:cgst_sgst))
    #     else
    #       invoice.update_columns(gst_type_id: GstType.id_for(:igst))
    #     end
    #   else
    #     invoice.update_columns(gst_type_id: GstType.id_for(:igst))
    #   end
    #   invoice.update_columns(discount_type_id: 1) if invoice.discount_type_id.blank?
    # end
  end
end
