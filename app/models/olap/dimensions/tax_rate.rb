class Olap::Dimensions::TaxRate < OlapRecord
  include Analytics::Mapper

  transaction_model ::TaxRate
  events 'tax_rate.update', 'tax_rate.create', 'tax_rate.destroy'

  map :name
  map :rate
  map :internal_id
  map :company_id
  map :is_deleted
  map :deleted_at
  map :cgst
  map :sgst
  map :igst
  map :igst_internal_id
  map :cgst_internal_id
  map :sgst_internal_id

end