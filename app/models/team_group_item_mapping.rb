# == Schema Information
#
# Table name: group_item_configuration_mappings
#
#  id                 :integer          not null, primary key
#  configuration_id   :integer          not null
#  user_group_id      :integer          not null
#  user_group_item_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  type_id            :integer          not null
#

class UserTeamGroupItemMapping < ActiveRecord::Base

  belongs_to :configuration, class_name: 'Team'
  belongs_to :user_group
  belongs_to :user_group_item

  validates :type_id, presence: true
  validates :configuration_id, presence: true
  validates :user_group_id, presence: true
  validates :user_group_item_id, presence: true, uniqueness: {scope: [:user_group_id, :configuration_id]}

  scope :with_type, ->(type_id) { where type_id: type_id }
  scope :with_user_group_item, ->(item_id) { where user_group_item_id: item_id }

end
