# == Schema Information
#
# Table name: user_teams
#
#  id         :integer          not null, primary key
#  company_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string(255)      not null
#

class UserTeam < ActiveRecord::Base

  validates :company_id, presence: true
  validates :name, presence: true, uniqueness: {scope: :company_id, :case_sensitive => false}

  has_many :user_team_group_item_mappings, dependent: :destroy
  has_many :user_groups, through: :user_team_group_item_mappings
  has_many :user_group_items, through: :user_team_group_item_mappings

  accepts_nested_attributes_for :user_team_group_item_mappings

end
