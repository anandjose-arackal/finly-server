# == Schema Information
#
# Table name: user_group_item_mappings
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  user_group_item_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  is_deleted         :boolean          default(FALSE)
#  group_id           :integer
#  user_group_id      :integer
#

class UserGroupItemMapping < ActiveRecord::Base
  include SoftDeletable

  belongs_to :user
  belongs_to :user_group_item

  scope :with_user, ->(user_id) { where user_id: user_id }
  scope :with_group, ->(group_id) { where group_id: group_id }
  scope :with_group_item, ->(group_item_id) { where user_group_item_id: group_item_id }

  validates :user_id, presence: true, uniqueness: {scope: :user_group_id}
  validates :user_group_id, presence: true
  validates :user_group_item_id, presence: true
end
