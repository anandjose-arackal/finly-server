Lookup::Router.draw do

  # Masters
  route 'policies', Masters::Policies::Lookup
  route "departments", Masters::Departments::Lookup
  route "locations", Masters::Locations::Lookup
  route "cost_centers", Masters::CostCenters::Lookup
  route "categories", Masters::Categories::Lookup
  route "vendors", Masters::Vendors::Lookup # Went with singular because plural was already being used by other areas of the app
  route "vendor_types", Masters::Vendors::Types::Lookup # Went with singular because plural was already being used by other areas of the app
  route 'vendor_locations', Masters::Vendors::Locations::Lookup
  route 'vendor_bank_accounts', Masters::Vendors::BankAccounts::Lookup
  route "items", Masters::Items::Lookup
  route "tax_rates", Masters::TaxRates::Lookup
  route "tds_slabs", Masters::TdsSlabs::Lookup
  route 'bbps_billers', Docs::UtilityBills::Billers::Lookup
  route 'users', Masters::Users::Lookup
  route "payment_terms", Masters::PaymentTerms::Lookup

  # Docs
  route 'purchase_requests', Docs::P2P::PurchaseRequests::Lookup

end