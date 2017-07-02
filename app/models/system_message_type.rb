# == Schema Information
#
# Table name: system_message_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SystemMessageType < ActiveRecord::Base

  VALUES = {
      info: 1,
      error: 2,
      success: 3
  }

  scope :with_id, -> (id) { where id: id }
  scope :with_name, -> (name) { where name: name }

  def self.id_for(key)
    VALUES[key]
  end

  def self.name_for(id)
    VALUES.key(id).to_s.humanize rescue nil
  end

  def self.seed_data
    count = SystemMessageType.count
    SystemMessageType::VALUES.each do |key, value|
      if count == 0 or SystemMessageType.with_name(key).blank?
        SystemMessageType.create id: value, name: key
      end
    end
  end

end
