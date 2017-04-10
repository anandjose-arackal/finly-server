class CreateCardPrograms < ActiveRecord::Migration
  def change
    create_table :card_programs do |t|
      t.string :name
      t.boolean :create_expense
      t.boolean :receive_reimbursement
      t.boolean :personal_wallet_fund_transfer
      t.boolean :spend_restrictions
      t.boolean :end_date_restrictions
      t.boolean :manager_credit
      t.boolean :manager_debit
      t.boolean :manager_blockable
      t.boolean :manager_view_balance
      t.boolean :manager_view_eligibility
      t.boolean :manager_view_transactions

      t.timestamps null: false
    end
    add_column :cards, :card_program_id, :integer, null: false, index: true, foreign_key: true, references: 'CardProgram'

    if CardProgram.with_name('Expense').blank?
      CardProgram.create id: CardProgram.id_for(:expense), name: 'Expense', create_expense: true, receive_reimbursement: false,
                         personal_wallet_fund_transfer: true, spend_restrictions: true,
                         end_date_restrictions: true, manager_credit: true, manager_debit: true,
                         manager_blockable: true, manager_view_balance: true, manager_view_eligibility: true,
                         manager_view_transactions: true
    end
    if CardProgram.with_name('Reimbursement').blank?
      CardProgram.create id: CardProgram.id_for(:reimbursement), name: 'Reimbursement', create_expense: false, receive_reimbursement: true,
                         personal_wallet_fund_transfer: false, spend_restrictions: false,
                         end_date_restrictions: true, manager_credit: false, manager_debit: false,
                         manager_blockable: false, manager_view_balance: false, manager_view_eligibility: true,
                         manager_view_transactions: false
    end

    cards = Card.all.with_card_program([nil, 0])
    new_card_program_id = CardProgram.first.id
    cards.each do |card|
      card.update_attribute(:card_program_id, new_card_program_id)
    end
  end
end
