class Categories::OutwardInvoiceLineItems::Index < Categories::Index

  def init
    self.company = user.company
    self.purpose_id = "outward_invoice_line_items"
    self.parent_type_id = FieldParentType.id_for(:outward_invoice_line_item)
  end

  def validate
    if self.purpose.blank?
      add_message :error, "Purpose cannot be blank"
    end
  end
end