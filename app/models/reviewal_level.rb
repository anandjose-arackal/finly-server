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
#

class ReviewalLevel < ActiveRecord::Base
  belongs_to :policy
  has_many :level_reviewer_mappings, foreign_key: :level_id
  has_many :reviewers, class_name: 'User', through: :level_reviewer_mappings


  validates :policy_id, presence: true
  validates :level_number, presence: true
  validates :associated_entity_type, presence: true
end
