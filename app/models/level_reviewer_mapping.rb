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
#  is_deleted  :boolean          default(FALSE), not null
#

class LevelReviewerMapping < ActiveRecord::Base
  include SoftDeletable

  belongs_to :level, class_name: 'ReviewalLevel'
  belongs_to :reviewer, class_name: 'User'

  validates :level_id, presence: true
  validates :reviewer_id, presence: true

  default_scope { unscope(:where) }

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
  scope :non_deleted, -> { where is_deleted: [nil, false] }

  scope :with_reviewer_id, -> (ids){
    where reviewer_id: ids
  }



end
