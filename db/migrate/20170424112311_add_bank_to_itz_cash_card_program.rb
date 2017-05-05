class AddBankToItzCashCardProgram < ActiveRecord::Migration
  def change
    add_column :itz_cash_card_programs, :bank, :string
  end
end
