class Masters::InwardInvoiceStatuses::Lookup < Lookup::API

  resolver 'inward_invoice_statuses.default'
  search_key :name_start

  attribute :id, visible: false
  attribute :name
end