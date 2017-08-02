# == Schema Information
#
# Table name: user_team_group_item_mappings
#
#  id                 :integer          not null, primary key
#  user_group_id      :integer          not null
#  user_group_item_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_team_id       :integer
#

class UserTeamGroupItemMapping < ActiveRecord::Base

  belongs_to :user_team
  belongs_to :user_group
  belongs_to :user_group_item

  # validates :user_team, presence: true
  validates :user_group_id, presence: true
  validates :user_group_item_id, presence: true, uniqueness: {scope: [:user_group_id, :user_team_id]}

  scope :with_id, ->(id) { where id: id }
  scope :with_type, ->(type_id) { where type_id: type_id }
  scope :with_user_group_item, ->(item_id) { where user_group_item_id: item_id }
  scope :with_user_team, ->(team_id) { where user_team_id: team_id }

end
