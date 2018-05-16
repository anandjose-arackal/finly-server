class BankTransfer::InwardInvoices::Base < BankTransfer::Base


  def invoice_attributes
    params.require(:invoice).permit(:note, :tax, :gst_type_id, :tds, :tds_type_id, :category_id, :cost_center_id, :tds_slab_id,
                                     :tax_type_id, :discount, :date, :discount_type_id, :due_date, :roundoff_amount,
                                     :invoice_number, :inclusive_of_taxes, :advance, :advance_type_id,
                                     original_amount_attributes: [:value, :currency_id],
                                     freight_amount_attributes: [:value, :currency_id],
                                     advance_amount_attributes: [:value, :currency_id],
                                     invoice_attachments_attributes: [:attached_file, :description, :remove_file],
                                     invoice_items_attributes: [:quantity, :rate, :tax, :discount, :category_id, :description, :id, :remove_line_item, :hsn_sac])
  end

end