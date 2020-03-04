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
#  user_group_id      :integer
#  deleted_at         :datetime
#

class UserGroupItemMapping < ApplicationRecord
  include SoftDeletable

  belongs_to :user, optional: true

  belongs_to :user_group_item, optional: true

  scope :with_user, ->(user_id) { where user_id: user_id }
  scope :with_group, ->(group_id) { where user_group_id: group_id }
  scope :with_group_item, ->(group_item_id) { where user_group_item_id: group_item_id }
  scope :group_by_user_id, -> { group :user_id }

  # This is used to check if user has exactly "N" number of Group Items. Used to identify users belonging to a group combination.
  # Ex: If User belongs to Bangalore + Sales, and team is made of of Bangalore + None,
  # to ensure users belonging to Bangalore + None is identified, this associaation count needs to be of size 1 to remove users belonging to sales or any other team
  scope :having_association_count, -> (count) { group_by_user_id.having('count(user_id) = ?', count) }
  scope :having_greater_than_association_count, -> (count) { group_by_user_id.having('count(user_id) >= ?', count) }
  # scope :users_having_group_items, ->(group_item_id)

  validates :user_id, presence: true
  validates :user_group_id, presence: true
  validates :user_group_item_id, presence: true
end
