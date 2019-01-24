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
#  threshold   :decimal(20, 5)
#

class LevelUserReviewerMapping < ActiveRecord::Base
  belongs_to :level, class_name: 'ReviewalLevel', optional: true
  belongs_to :user, class_name: 'User', optional: true
  belongs_to :reviewer, class_name: 'User', optional: true
  belongs_to :policy, optional: true

  validates :level_id, presence: true
  validates :reviewer_id, presence: true
  validates :policy_id, presence: true
  validates :user_id, presence: true

  scope :with_reviewer_id, -> (reviewer_id) {
    where reviewer_id: reviewer_id
  }

  # Finds all the MAX amounts which are less than the amount passed
  # Find thes the mappings with max threshold which are lteq amount
  scope :with_threshold, -> (amount) {
    where('threshold = ?', where('threshold <= ?', amount).maximum("threshold"))
  }
  scope :with_level_id, -> (ids) {
    where level_id: ids
  }

  scope :with_user_id, -> (ids) {
    where user_id: ids
  }

  scope :with_reviewer_id, -> (ids){
    where reviewer_id: ids
  }

end
