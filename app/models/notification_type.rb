# == Schema Information
#
# Table name: notification_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class NotificationType < ActiveRecord::Base

  VALUES = {user: 1, report: 2, payment: 3, card: 4, expense: 5, settlement: 6, advance_request: 7}

  self.class.instance_eval do
    VALUES.each do |key, value|
      define_method "#{key}_id" do
        value
      end
    end
  end


end
