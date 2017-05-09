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