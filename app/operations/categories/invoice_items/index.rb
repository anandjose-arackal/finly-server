class Categories::InvoiceItems::Index < Categories::Index

  def init
    self.company = user.company
    self.purpose = "inward_invoice_line_items"
    self.parent_type_id = FieldParentType.id_for(:invoice_line_item)
  end

  def validate
    if self.purpose.blank?
      add_message :error, "Purpose cannot be blank"
    end
  end

  def process
    self.categories = self.company.categories.with_purpose(self.purpose)
    self.custom_fields = self.company.field_configurations.with_parent_type(self.parent_type_id)
  end

end