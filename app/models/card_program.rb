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
#  non_personal_fund_transfer    :boolean
#

class CardProgram < ActiveRecord::Base
  has_many :cards

  scope :with_id, -> (id){ where id: id }
  scope :with_name, -> (name){ where name: name }
  scope :with_manager_credit, -> { where manager_credit: true }
  scope :with_reimbursement, -> { where receive_reimbursement: true }
  scope :with_non_personal_fund_transfer, -> { where non_personal_fund_transfer: true }
  scope :with_manager_view_transactions, -> { where manager_view_transactions: true }
  scope :expense, -> {where id: PROGRAMS[:expense]}

  PROGRAMS = {expense: 1, reimbursement: 2, meal: 3, medical: 4}

  PROGRAM_DETAILS = {expense: {id: PROGRAMS[:expense],
                               name: 'Expense',
                               create_expense: true,
                               receive_reimbursement: false,
                               personal_wallet_fund_transfer: true,
                               spend_restrictions: true,
                               end_date_restrictions: true,
                               manager_credit: true,
                               manager_debit: true,
                               manager_blockable: true,
                               manager_view_balance: true,
                               manager_view_eligibility: true,
                               manager_view_transactions: true,
                               non_personal_fund_transfer: true},
                     reimbursement: {id: PROGRAMS[:reimbursement],
                                     name: 'Reimbursement',
                                     create_expense: false,
                                     receive_reimbursement: true,
                                     personal_wallet_fund_transfer: false,
                                     spend_restrictions: false,
                                     end_date_restrictions: true,
                                     manager_credit: true,
                                     manager_debit: false,
                                     manager_blockable: false,
                                     manager_view_balance: false,
                                     manager_view_eligibility: true,
                                     manager_view_transactions: false,
                                     non_personal_fund_transfer: false},
                     meal: {id: PROGRAMS[:meal],
                            name: 'Meal',
                            create_expense: false,
                            receive_reimbursement: false,
                            personal_wallet_fund_transfer: false,
                            spend_restrictions: false,
                            end_date_restrictions: true,
                            manager_credit: false,
                            manager_debit: false,
                            manager_blockable: false,
                            manager_view_balance: false,
                            manager_view_eligibility: false,
                            manager_view_transactions: false,
                            non_personal_fund_transfer: false},
                     medical: {id: PROGRAMS[:medical],
                            name: 'Medical',
                            create_expense: false,
                            receive_reimbursement: false,
                            personal_wallet_fund_transfer: false,
                            spend_restrictions: false,
                            end_date_restrictions: true,
                            manager_credit: false,
                            manager_debit: false,
                            manager_blockable: false,
                            manager_view_balance: false,
                            manager_view_eligibility: false,
                            manager_view_transactions: false,
                            non_personal_fund_transfer: false}
  }

  def self.id_for(program)
    PROGRAMS[program]
  end

  def self.seed_data
    CardProgram::PROGRAM_DETAILS.each do |key, value|
      name = value[:name]
      if CardProgram.with_name(name).blank?
        CardProgram.create value
      end
    end
  end

  def card_program_name
    self.name
  end

end
