class UserGroupConfigurationType < ActiveRecord::Base

  VALUES = {card_restriction: 1}

  def self.id_for(sym)
    VALUES[sym]
  end

  def self.seed_data
    count = UserGroupConfigurationType.count
  end

end
