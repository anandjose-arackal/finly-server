class Olap::Dimensions::Department < OlapRecord
  include Analytics::Mapper

  transaction_model ::Department
  events 'department.update', 'department.create'
  # dimension Olap::Dimensions::Department

  map :name
  map :company_id
  map :created_at
  map :updated_at
  map :is_deleted
  map :ancestry
  map :cost_center_id
  map :deleted_at
  map :department_code
  map :code
  map :gl_code

end
