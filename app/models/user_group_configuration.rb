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

class UserGroupConfiguration < ActiveRecord::Base

  validates :company_id, presence: true
  validates :type_id, presence: true
  validate :uniqueness_check

  has_many :group_item_configuration_mappings
  belongs_to :type, class_name: 'UserGroupConfigurationType'

  accepts_nested_attributes_for :group_item_configuration_mappings

  def uniqueness_check

  end

end
