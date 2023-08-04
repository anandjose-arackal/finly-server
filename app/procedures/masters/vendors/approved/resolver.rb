class Masters::Vendors::Approved::Resolver < Resolver::API

  entity YesBankVendor

  def load(params)
    return user.company.yes_bank_vendors.approved
    ::YesBankVendor.none
  end

end