# == Schema Information
#
# Table name: level_reviewer_mappings
#
#  id          :integer          not null, primary key
#  level_id    :integer
#  reviewer_id :integer
#  threshold   :decimal(20, 5)   default(0.0)
#  exception   :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class LevelReviewerMapping < ActiveRecord::Base
  belongs_to :level, class_name: 'ReviewalLevel'
  belongs_to :reviewer, class_name: 'User'

  validates :level_id, presence: true
  validates :reviewer_id, presence: true

  scope :with_threshold, -> (amount) {
    where('threshold <= ?', amount)
  }
end
