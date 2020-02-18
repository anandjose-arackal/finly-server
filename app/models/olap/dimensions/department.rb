# == Schema Information
#
# Table name: olap_dimensions_departments
#
#  id                   :bigint           not null, primary key
#  finly_ref_id         :bigint           not null
#  finly_ref_created_at :datetime
#  finly_ref_updated_at :datetime
#  name                 :string(255)
#  company_id           :integer
#  is_deleted           :boolean
#  ancestry             :string(255)
#  cost_center_id       :integer
#  deleted_at           :datetime
#  department_code      :string(255)
#  code                 :string(255)
#  gl_code              :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  uuid                 :string(36)       not null
#

class Olap::Dimensions::Department < OlapRecord
  include Events::Consumer
include Analytics::Mapper

  transaction_model ::Department
  consume 'department.update', 'department.create', 'department.destroy'

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
