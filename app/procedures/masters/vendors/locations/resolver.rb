class Masters::Vendors::Locations::Resolver < Masters::Vendors::Resolver

  entity GstinLocation

  def load(params)
    vendors = super(params)
    if vendors.count > 10
      vendors = vendors.first(10)
    end
    GstinLocation.where("`gstin_locations`.`vendor_id` IN (#{vendors.pluck(:id).join(',')})")
  end

end