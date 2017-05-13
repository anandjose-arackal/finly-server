# == Schema Information
#
# Table name: user_group_configurations
#
#  id         :integer          not null, primary key
#  company_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  type_id    :integer          not null
#

class UserTeam < ActiveRecord::Base

  validates :company_id, presence: true
  validate :uniqueness_check

  has_many :user_team_group_item_mappings

  accepts_nested_attributes_for :user_team_group_item_mappings

  def uniqueness_check

  end

end
