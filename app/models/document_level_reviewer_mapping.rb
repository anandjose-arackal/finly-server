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
#  level_number                    :integer
#  taken_control                   :boolean          default(FALSE)
#  taken_control_by_id             :integer
#  viewable                        :boolean          default(FALSE)
#  became_viewable_at              :datetime
#  action_taken_by_id              :integer
#  action_id                       :integer
#  provider_name                   :string(255)
#

class DocumentLevelReviewerMapping < ActiveRecord::Base

  # When a single reviewer is selected from each level in the reviewal chain
  # a new mapping is created. If nothing is selected it falls back to reviewer(s) in the
  # level
  belongs_to :policy
  belongs_to :level, class_name: 'ReviewalLevel'
  belongs_to :reviewer, class_name: 'User'
  belongs_to :document_reviewer_mappable, polymorphic: true
  belongs_to :taken_control_by, class_name: 'User'
  belongs_to :action_taken_by, class_name: 'User'
  belongs_to :action, class_name: 'TrailAction'

  scope :with_level_ids, -> (ids) {where level_id: ids}
  scope :with_level_id, -> (ids) {where level_id: ids}
  scope :with_reviewer_ids, -> (ids) {where reviewer_id: ids}
  scope :not_with_reviewer_ids, ->(id) { where.not reviewer_id: id }
  scope :with_policy_ids, -> (ids) {where policy_id: ids}
  scope :with_document_type, -> (document_type) {where document_reviewer_mappable_type: document_type}
  scope :with_taken_control, -> { where taken_control: true }
  scope :with_level_number, -> (number) {where level_number: number}
  scope :with_provider_name, -> (name) {where provider_name: name}
  scope :with_action_id, -> (action_id) {where action_id: action_id}

  scope :with_document_id, -> (document_ids) {where document_reviewer_mappable_id: document_ids}

  validates :policy_id, presence: true
  validates :level_id, presence: true
  validates :document_reviewer_mappable_id, presence: true
  validates :document_reviewer_mappable_type, presence: true
end
