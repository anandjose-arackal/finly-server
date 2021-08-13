class Masters::Vendors::Locations::Resolver < Resolver::API

  entity GstinLocation

  # Adding this skip filtering for child items.
  def self.is_items_resolver?
    true
  end

  def load(params)
    vendors = Resolver::Router.dispatch('vendors.default', { params: params, current_user: user })
    GstinLocation.where("`gstin_locations`.`vendor_id` IN (#{vendors.select(:id).to_sql})")
  end

end