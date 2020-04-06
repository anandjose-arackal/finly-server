# == Schema Information
#
# Table name: olap_dimensions_locations
#
#  id                    :bigint           not null, primary key
#  finly_ref_id          :bigint           not null
#  finly_ref_created_at  :datetime
#  finly_ref_updated_at  :datetime
#  name                  :string(255)
#  gstin                 :string(255)
#  pan                   :string(255)
#  company_id            :integer
#  address_1             :text(65535)
#  address_2             :text(65535)
#  city                  :string(255)
#  state_id              :integer
#  country               :string(255)
#  pin                   :string(255)
#  contact_name          :string(255)
#  contact_mobile_number :string(255)
#  is_deleted            :boolean
#  deleted_at            :datetime
#  location_code         :string(255)
#  ancestry              :string(255)
#  nature_of_office      :string(255)
#  billable_location     :boolean
#  shippable_location    :boolean
#  gl_code               :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  uuid                  :string(36)       not null
#

class Olap::Dimensions::Location < OlapRecord
  include Events::Consumer
  include Analytics::Mapper

  transaction_model ::BranchLocation
  consume 'branch_location.update', 'branch_location.create', 'branch_location.destroy'

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
