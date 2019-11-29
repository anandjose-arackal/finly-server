class Olap::Dimensions::CostCenter < OlapRecord
  include Analytics::Mapper

  transaction_model ::CostCenter
  events 'cost_center.update', 'cost_center.create', 'cost_center.destroy'

  map :name
  map :application
  map :company_id
  map :is_deleted
  map :deleted_at
  map :cost_center_code
  map :ancestry
  map :gl_code

end
