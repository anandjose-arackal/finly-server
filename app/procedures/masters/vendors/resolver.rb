class Masters::Vendors::Resolver < Resolver::API

  entity YesBankVendor

  def load(params)
    user.company.yes_bank_vendors
  end

end