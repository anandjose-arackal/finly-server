# == Schema Information
#
# Table name: policy_location_department_mappings
#
#  id            :bigint           not null, primary key
#  location_id   :integer
#  department_id :integer
#  policy_id     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  company_id    :integer
#  creator_id    :integer
#

class PolicyLocationDepartmentMapping < ApplicationRecord

  belongs_to :policy, optional: true
  belongs_to :location, optional: true
  belongs_to :department, optional: true
  belongs_to :company, optional: true
end
