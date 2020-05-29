class Masters::Vendors::Locations::Resolver < Masters::Vendors::Resolver

  entity GstinLocation

  def load(params)
    vendors = super(params)
    GstinLocation.where('vendor_id in (?)', vendors.to_sql)
  end

end