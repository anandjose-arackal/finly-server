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
#

class UserGroupItemMapping < ActiveRecord::Base
  include SoftDeletable

  belongs_to :user
  belongs_to :user_group_item
end
