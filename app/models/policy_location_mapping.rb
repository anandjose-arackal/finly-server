# == Schema Information
#
# Table name: policy_location_mappings
#
#  id          :bigint(8)        not null, primary key
#  policy_id   :integer
#  location_id :integer
#  enabled     :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class PolicyLocationMapping < ApplicationRecord

  belongs_to :policy, optional: true
  belongs_to :location, optional: true, class_name: 'BranchLocation'
end
