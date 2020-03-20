class YesBankVendorDrop < Drop

  def business_name
    record&.business_name
  end

  def gl_name
    business_name
  end

end