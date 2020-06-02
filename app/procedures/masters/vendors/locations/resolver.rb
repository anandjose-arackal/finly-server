class Masters::Vendors::Locations::Resolver < Masters::Vendors::Resolver

  entity GstinLocation

  def load(params)
    vendors = super(params)
    GstinLocation.where("`gstin_locations`.`vendor_id` IN (#{vendors.select(:id).to_sql})")
  end

end