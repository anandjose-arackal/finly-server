# == Schema Information
#
# Table name: user_group_items
#
#  id            :integer          not null, primary key
#  name          :string(255)      not null
#  user_group_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  is_deleted    :boolean          default(FALSE)
#

class UserGroupItem < ActiveRecord::Base
  include SoftDeletable

  belongs_to :user_group
  has_many :user_group_item_mappings
  has_many :users, through: :user_group_item_mappings

  validates :name, uniqueness: {scope: :user_group_id}

  scope :with_user_group, ->(user_group_id) { where user_group_id: user_group_id }
  scope :with_id, ->(id) { where id: id }

  before_destroy do
    UserGroupItemMapping.with_group_item(self.id).destroy_all
  end

end
