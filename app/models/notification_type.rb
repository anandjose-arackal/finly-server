# == Schema Information
#
# Table name: notification_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class NotificationType < ApplicationRecord

  VALUES = {
      user: 1, report: 2, payment: 3, card: 4, expense: 5, settlement: 6, money_request: 7, wallet: 8, bank_payment_request: 9,
      purchase_order: 10, invoice: 11, vendor: 12
  }

  def self.seed_data
    VALUES.each do |name, id|
      unless NotificationType.find_by(name: name)
        NotificationType.create(id: id, name: name)
      end
    end
  end

  self.class.instance_eval do
    VALUES.each do |key, value|
      define_method "#{key}_id" do
        value
      end
    end
  end

  def self.id_for(sym)
    VALUES[sym]
  end


end
