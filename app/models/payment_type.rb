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
           credit_meal_card: 21}

  # TYPES = {advance: 1, debt_clearance: 2, reimbursement: 3, settlement: 4,
  #          credit_from_virtual_account_to_wallet: 5,
  #          credit_from_virtual_account_to_card: 6,
  #          credit_from_wallet_to_wallet: 7,
  #          credit_from_wallet_to_card: 8,add_payment_type_credit_meal_card
  #          debit_from_wallet_to_wallet: 9,
  #          debit_from_wallet_to_virtual_account: 10,
  #          atm_withdrawal: 11}

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
