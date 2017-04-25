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

class ItzCashCardProgram < ActiveRecord::Base


  BANKS = {hdfc: 1, rbl: 2, kotak: 3}

  PROGRAM_DETAILS = [
      {
          name: "HDFC Expense",
          bank: "HDFC",
          product_code: "HDFFIN",
      },
      {
          name: "RBL Expense",
          bank: "RBL",
          product_code: "RBLRFN",
      },
      {
          name: "Kotak Reimbursement",
          bank: "Kotak",
          product_code: "KOTAKC",
      }
  ]

  def self.seed_data
    PROGRAM_DETAILS.each do |detail|
      ItzCashCardProgram.create(detail)
    end
  end

  def self.id_for(name)
    BANKS[name]
  end

  def itz_cash_card_program_name
    self.name
  end

end
