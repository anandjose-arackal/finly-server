class AddMealCardProgram < ActiveRecord::Migration
  def change
    if CardProgram.count > 0 and CardProgram.with_name('Meal').blank?
      CardProgram.create id: CardProgram.id_for(:meal),
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
                         non_personal_fund_transfer: false
    end
  end
end
