
# == Schema Information
#
# Table name: itz_cash_card_programs
#
#  id           :integer          not null, primary key
#  product_code :string(255)
#  charge_code  :string(255)
#  name         :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  bank         :string(255)
#

class ItzCashCardProgram < ApplicationRecord

  scope :with_product_code, -> (product_code) { where product_code: product_code }

  BANKS = {hdfc: 1, rbl: 2, kotak: 3, rbl_visa: 16, hdfc_pin_at_pos: 17}

  PROGRAM_DETAILS = [
      {
          name: "HDFC Expense",
          bank: "HDFC",
          product_code: "HDFFIN",
      },
      {
          name: "RBL Expense (RBL)",
          bank: "RBL",
          product_code: "RBLRFN",
      },
      {
          name: "Kotak Reimbursement",
          bank: "Kotak",
          product_code: "KOTAKC",
      },
      {
          name: "RBL Expense (Visa)",
          bank: "RBL",
          product_code: "RBLFIN"
      },
      {
          name: "HDFC (PIN at POS)",
          bank: "HDFC",
          product_code: "HDFFPD"
      },
      {
          name: "Jotun Reward Card",
          bank: "HDFC",
          product_code: "FNHREW"
      },
      {
          name: "HDFC Chip card",
          bank: "HDFC",
          product_code: "HDFFRG",
          charge_code: "HBFRGD"
      }
  ]

  def self.seed_data
    if Rails.env.production?
      PROGRAM_DETAILS.each do |detail|
        if ItzCashCardProgram.with_product_code(detail[:product_code]).blank?
          ItzCashCardProgram.create(detail)
        end
      end
    else
      if ItzCashCardProgram.count == 0
        ItzCashCardProgram.create(name: 'Test HDFC Card', bank: 'HDFC', product_code: 'NGPRHD')
      end
    end
  end

  def self.id_for(name)
    BANKS[name]
  end

  def itz_cash_card_program_name
    self.name
  end

end
