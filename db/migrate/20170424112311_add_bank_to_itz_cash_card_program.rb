class AddBankToItzCashCardProgram < ActiveRecord::Migration[4.2]
  def change
    add_column :itz_cash_card_programs, :bank, :string
  end
end
