class GroupItemConfigurationMapping < ActiveRecord::Base

  belongs_to :user_group_configuration
  belongs_to :user_group
  belongs_to :user_group_item

  validates :type_id, presence: true
  validates :user_group_configuration_id, presence: true
  validates :user_group_id, presence: true
  validates :user_group_item_id, presence: true, uniqueness: {scope: [:user_group_id, :user_group_configuration_id]}

  scope :with_type, ->(type_id) { where type_id: type_id }
  scope :with_user_group_item, ->(item_id) { where user_group_item_id: item_id }

end
