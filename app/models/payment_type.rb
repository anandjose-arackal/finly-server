# == Schema Information
#
# Table name: payment_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#



class PaymentType < ActiveRecord::Base
  has_many :payments

  TYPES = {add_cash_on_hand: 1,
           deduct_cash_on_hand: 2,
           reimbursement: 3,
           settlement: 4,
           atm_withdrawal: 11,
           credit: 18,
           debit: 19,
           reimbursement_outside_finly: 20,
           credit_meal_card: 21,
           credit_medical_card: 22,
           credit_expense_card: 23,
           credit_reimbursement_card: 24
         }

  # TYPES = {
  #     credit: 18,
  #     debit: 19
  # }

  scope :with_id, -> (id) { where id: id }
  scope :with_name, -> (name) { where name: name }

  def self.id_for(key)
    TYPES[key]
  end

  def self.name_for(id)
    TYPES.key(id).to_s.humanize rescue nil
  end

  def self.seed_data
    count = PaymentType.count
    PaymentType::TYPES.each do |key, value|
      if count == 0 or PaymentType.with_name(key).blank?
        PaymentType.create id: value, name: key
      end
    end
  end

end
