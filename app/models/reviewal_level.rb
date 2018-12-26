# == Schema Information
#
# Table name: reviewal_levels
#
#  id                     :integer          not null, primary key
#  level_number           :integer
#  policy_id              :integer
#  associated_entity_type :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string(255)
#  is_deleted             :boolean          default(FALSE), not null
#

class ReviewalLevel < ActiveRecord::Base
  include SoftDeletable

  belongs_to :policy
  has_many :level_reviewer_mappings, foreign_key: :level_id, dependent: :destroy
  has_many :reviewers, class_name: 'User', through: :level_reviewer_mappings

  validates :policy_id, presence: true
  validates :level_number, presence: true
  validates :associated_entity_type, presence: true

  default_scope { unscope(:where) }

  scope :with_id, -> (ids) { where id: ids }
  scope :with_entity_type, -> (type) { where associated_entity_type: type }
  scope :with_level_number, -> (number) { where level_number: number }
  scope :with_policy_ids, -> (ids) {where policy_id: ids}
  scope :non_deleted, -> { where is_deleted: [false, nil] }

  # alias_method :filter_associated_entity_type, :with_entity_type
  # alias_method :filter_policy, :with_policy_ids

  # Since you can alias scopes as they are class methods, you have use the below method
  singleton_class.send :alias_method, :filter_associated_entity_type, :with_entity_type
  singleton_class.send :alias_method, :filter_policy, :with_policy_ids
  singleton_class.send :alias_method, :filter_policy_id, :with_policy_ids
  singleton_class.send :alias_method, :with_ids, :with_id
end
