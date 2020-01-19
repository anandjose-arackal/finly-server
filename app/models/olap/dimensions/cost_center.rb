# == Schema Information
#
# Table name: olap_dimensions_cost_centers
#
#  id                   :bigint           not null, primary key
#  finly_ref_id         :bigint           not null
#  finly_ref_created_at :datetime
#  finly_ref_updated_at :datetime
#  name                 :string(255)
#  application          :string(255)
#  company_id           :integer
#  is_deleted           :boolean
#  deleted_at           :datetime
#  cost_center_code     :string(255)
#  ancestry             :string(255)
#  gl_code              :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  uuid                 :string(36)       not null
#

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
