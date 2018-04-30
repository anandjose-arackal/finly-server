class Categories::OutwardInvoices::Index < Categories::Index

  def init
    self.company = user.company
    self.purpose = "outward_invoices"
    self.parent_type_id = FieldParentType.id_for(:outward_invoice)
  end

  def validate
    if self.purpose.blank?
      add_message :error, "Purpose cannot be blank"
    end
  end

end