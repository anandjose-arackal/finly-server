# == Schema Information
#
# Table name: user_branch_location_mappings
#
#  id                 :bigint           not null, primary key
#  user_id            :integer          not null
#  branch_location_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  deleted_at         :datetime
#

class UserBranchLocationMapping < ApplicationRecord
  belongs_to :company, optional: true
  belongs_to :user
  belongs_to :branch_location
end
