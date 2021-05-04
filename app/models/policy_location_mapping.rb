# == Schema Information
#
# Table name: policy_location_mappings
#
#  id          :bigint           not null, primary key
#  policy_id   :integer
#  location_id :integer
#  enabled     :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  deleted_at  :datetime
#

class PolicyLocationMapping < ApplicationRecord

  belongs_to :company, optional: true
  belongs_to :policy, optional: true
  belongs_to :location, optional: true, class_name: 'BranchLocation'
end
