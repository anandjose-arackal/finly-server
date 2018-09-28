# == Schema Information
#
# Table name: document_level_reviewer_mappings
#
#  id                              :integer          not null, primary key
#  policy_id                       :integer
#  level_id                        :integer
#  reviewer_id                     :integer
#  document_reviewer_mappable_id   :integer          not null
#  document_reviewer_mappable_type :string(255)      not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

class DocumentLevelReviewerMapping < ActiveRecord::Base

  # When a single reviewer is selected from each level in the reviewal chain
  # a new mapping is created. If nothing is selected it falls back to reviewer(s) in the
  # level
  belongs_to :policy
  belongs_to :level, class_name: 'ReviewalLevel'
  belongs_to :reviewer, class_name: 'User'
  belongs_to :document_reviewer_mappable, polymorphic: true

  scope :with_level_ids, -> (ids) {where level_id: ids}
  scope :with_reviewer_ids, -> (ids) {where reviewer_id: ids}
  scope :with_policy_ids, -> (ids) {where policy_id: ids}
  scope :with_document_type, -> (document_type) {where document_reviewer_mappable_type: document_type}

  validates :policy_id, presence: true
  validates :level_id, presence: true
  validates :document_reviewer_mappable_id, presence: true
  validates :document_reviewer_mappable_type, presence: true
end
