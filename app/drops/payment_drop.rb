class PaymentDrop < Drop

  def date
    @object.date
  end

  def narration
    @object.note
  end

  def reference_id
    @object.external_reference_id
  end

  def gl_name
    @object.gl_name
  end

  def vendor
    return nil unless @object.receiving_user_type == "YesBankVendor"

    @object.receiving_user&.to_liquid
  end

  def beneficiary
    vendor
  end

  def amount
    @object.amount&.value || 0
  end

end