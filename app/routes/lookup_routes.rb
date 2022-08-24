Lookup::Router.draw do



  # Masters
  route 'policies', Masters::Policies::Lookup
  route "departments", Masters::Departments::Lookup
  route "locations", Masters::Locations::Lookup
  route "states", Masters::States::Lookup
  route "cost_centers", Masters::CostCenters::Lookup
  route "categories", Masters::Categories::Lookup
  route "vendors", Masters::Vendors::Lookup # Went with singular because plural was already being used by other areas of the app
  route "vendor_types", Masters::Vendors::Types::Lookup # Went with singular because plural was already being used by other areas of the app
  route 'vendor_locations', Masters::Vendors::Locations::Lookup
  route 'vendor_bank_accounts', Masters::Vendors::BankAccounts::Lookup
  route "items", Masters::Items::Lookup
  route "tax_rates", Masters::TaxRates::Lookup
  route "tax_types", Masters::TaxTypes::Lookup
  route "tds_slabs", Masters::TdsSlabs::Lookup
  route 'bbps_billers', Docs::UtilityBills::Billers::Lookup
  route 'users', Masters::Users::Lookup
  route "payment_terms", Masters::PaymentTerms::Lookup
  route "form_currencies", Masters::FormCurrencies::Lookup
  route "inward_invoice_statuses", Masters::InwardInvoiceStatuses::Lookup
  route "purchase_order_statuses", Masters::PurchaseOrderStatuses::Lookup
  route "purchase_request_statuses", Masters::PurchaseRequestStatuses::Lookup
  route "currencies", Masters::Currencies::Lookup
  route "countries", Masters::Countries::Lookup
  route "adjustable_credit_notes", Masters::AdjustableCreditNotes::Lookup
  route "advance_amount_statuses", Masters::AdvanceAmountStatuses::Lookup
  route "credit_note_statuses", Masters::CreditNoteStatuses::Lookup
  route "credit_note_item_types", Masters::CreditNoteItemTypes::Lookup

  # Docs
  route 'purchase_requests', Docs::P2P::PurchaseRequests::Lookup

  route 'master_schemas', Masters::Schema::Lookup
  route 'masters.*', Masters::Schema::Records::Lookup

end