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
  validate :uniqueness_check

  has_many :user_team_group_item_mappings

  accepts_nested_attributes_for :user_team_group_item_mappings

  def uniqueness_check

  end

end
