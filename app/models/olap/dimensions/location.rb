class Olap::Dimensions::Location < OlapRecord
  include Analytics::Mapper

  transaction_model ::BranchLocation
  events 'branch_location.update', 'branch_location.create', 'branch_location.destroy'

  map :name
  map :gstin
  map :pan
  map :company_id
  map :address_1
  map :address_2
  map :city
  map :state_id
  map :country
  map :pin
  map :contact_name
  map :contact_mobile_number
  map :is_deleted
  map :deleted_at
  map :location_code
  map :ancestry
  map :nature_of_office
  map :billable_location
  map :shippable_location
  map :gl_code

end
