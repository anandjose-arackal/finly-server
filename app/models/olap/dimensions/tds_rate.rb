class Olap::Dimensions::TdsRate < OlapRecord
  include Analytics::Mapper

  transaction_model ::TdsRatesList
  events 'tds_rate.update', 'tds_rate.create', 'tds_rate.destroy'

  map :name
  map :tds
  map :company_id
  map :gl_code
  map :deleted_at

end
