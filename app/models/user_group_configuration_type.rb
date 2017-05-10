# == Schema Information
#
# Table name: user_group_configuration_types
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string(255)      not null
#

class UserGroupConfigurationType < ActiveRecord::Base

  VALUES = {card_restriction: 1}

  scope :with_name, ->(name) { where name: name }

  def self.id_for(sym)
    VALUES[sym]
  end

  def self.name_for(id)
    VALUES.key(id)
  end

  def self.seed_data
    count = UserGroupConfigurationType.count
    UserGroupConfigurationType::VALUES.each do |key, value|
      if count == 0 or UserGroupConfigurationType.with_name(key)
        UserGroupConfigurationType.create id: value, name: key
      end
    end
  end

end
