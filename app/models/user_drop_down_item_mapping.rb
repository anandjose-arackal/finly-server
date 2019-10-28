# == Schema Information
#
# Table name: user_drop_down_item_mappings
#
#  id                :bigint           not null, primary key
#  user_id           :integer
#  drop_down_item_id :integer
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class UserDropDownItemMapping < ApplicationRecord
  include SoftDeletable

  belongs_to :user
  belongs_to :drop_down_item, class_name: "FieldDropDownItem"

  scope :with_drop_down_item_id, -> (drop_down_item_id) {
    where(drop_down_item_id: drop_down_item_id)
  }

  scope :with_user_id, -> (user_ids) {
    where(user_id: user_ids)
  }
  
end
