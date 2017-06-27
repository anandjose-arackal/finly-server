class EnableManagerCreditForReimbursement < ActiveRecord::Migration
  def up
    card_program = CardProgram.find(CardProgram.id_for(:reimbursement))
    card_program.update({manager_credit: true, non_personal_fund_transfer: true})
  end

  def down
    card_program = CardProgram.find(CardProgram.id_for(:reimbursement))
    card_program.update({manager_credit: false, non_personal_fund_transfer: false})

  end


end
