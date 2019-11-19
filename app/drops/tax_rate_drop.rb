class TaxRateDrop < Drop

  def name
    @object.name
  end

  def rate
    @object.rate
  end

  def cgst
    @object.cgst
  end

  def sgst
    @object.sgst
  end

  def igst
    @object.igst
  end

  def display_name
    @object.display_name
  end


end