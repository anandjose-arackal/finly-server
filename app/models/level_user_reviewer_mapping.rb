# == Schema Information
#
# Table name: level_user_reviewer_mappings
#
#  id          :integer          not null, primary key
#  level_id    :integer
#  user_id     :integer
#  reviewer_id :integer
#  policy_id   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class LevelUserReviewerMapping < ActiveRecord::Base
  belongs_to :level, class_name: 'ReviewalLevel'
  belongs_to :user, class_name: 'User'
  belongs_to :reviewer, class_name: 'User'
  belongs_to :policy
end
