class PaymentDrop < Drop

  def date
    @object.date
  end

  def narration
    @object.narration
  end

  def reference_id
    @object.reference_id
  end

  def gl_name
    @object.gl_name
  end

  def vendor
    @object.vendor
  end

  def beneficiary
    vendor
  end

  def net_amount
    @object.net_amount
  end

end