class Category::InvoiceItems::Index < Category::Base


  def init
    self.company = user.company
    self.purpose_id = Purpose.id_for(:invoice_items)
    self.parent_type_id = FieldParentType.id_for(:invoice_line_item)
  end

  def validate
    if self.purpose_id.blank?
      add_message :error, "Purpose cannot be blank"
    end
  end

end