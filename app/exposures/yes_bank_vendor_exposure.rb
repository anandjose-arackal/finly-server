class YesBankVendorExposure < Exposures::API

  def business_name
    record&.business_name
  end

  def gl_name
    business_name
  end

  def vendor_id
    record.vendor_id
  end

end