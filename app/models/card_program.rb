# == Schema Information
#
# Table name: card_programs
#
#  id                            :integer          not null, primary key
#  name                          :string(255)
#  create_expense                :boolean
#  receive_reimbursement         :boolean
#  personal_wallet_fund_transfer :boolean
#  spend_restrictions            :boolean
#  end_date_restrictions         :boolean
#  manager_credit                :boolean
#  manager_debit                 :boolean
#  manager_blockable             :boolean
#  manager_view_balance          :boolean
#  manager_view_eligibility      :boolean
#  manager_view_transactions     :boolean
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#

class CardProgram < ActiveRecord::Base

  has_many :cards

  PROGRAMS = {expense: 1, reimbursement: 2}

  def self.id_for(program)
    PROGRAMS[program]
  end

end
