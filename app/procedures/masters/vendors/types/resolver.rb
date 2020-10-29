class Masters::Vendors::Types::Resolver < Resolver::API

  entity VendorType

  def load(params)
    user.company.vendor_types
  end
end

