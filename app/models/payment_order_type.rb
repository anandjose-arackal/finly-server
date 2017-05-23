# == Schema Information
#
# Table name: payment_order_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PaymentOrderType < ActiveRecord::Base

  VALUES = {meal_card: 1, medical_card: 2, expense_card: 3, reimbursement_card: 4}
  # Fund Transfers, Meal Card, Gift Card, Gift Voucher, Personal

  validates :name, presence: true

  scope :with_name, ->(name) { where name: name }

  def self.id_for(key)
    VALUES[key]
  end

  def self.seed_data
    count == PaymentOrderType.count
    VALUES.each do |key, value|
      if count == 0 or PaymentOrderType.with_name(key).blank?
        PaymentOrderType.create id:value, name: key
      end
    end
  end

end
