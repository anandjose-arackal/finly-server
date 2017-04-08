# == Schema Information
#
# Table name: admin_user_roles
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AdminUserRole < ActiveRecord::Base

  VALUES = {
    admin: 1,
    transcriber: 2
  }

  def self.seed_data
    if AdminUserRole.count == 0
      VALUES.each do |key, value|
        AdminUserRole.create( id: value, name: key)
      end
    end
  end

end
