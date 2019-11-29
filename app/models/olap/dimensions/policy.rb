class Olap::Dimensions::Policy < OlapRecord
  include Analytics::Mapper

  transaction_model ::Policy
  events 'policy.update', 'policy.create', 'policy.destroy'

  map :name
  map :company_id
  map :owner_id
  map :default
  map :is_deleted
  map :description
  map :base_currency_id
  map :application
  map :settlement_currency_id
  map :deleted_at

end