class TaxRateDrop < Drop

  def name
    record.name
  end

  def rate
    record.rate
  end

  def cgst
    record.cgst
  end

  def sgst
    record.sgst
  end

  def igst
    record.igst
  end

  def display_name
    record.display_name
  end


end