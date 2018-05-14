class Categories::VendorPayments::Index < Categories::Index

  def init
    self.company = user.company
    self.purpose = "vendor_payments"
    self.parent_type_id = FieldParentType.id_for(:invoice)
  end

  def validate
    if self.purpose.blank?
      add_message :error, "Purpose cannot be blank"
    end
  end

end