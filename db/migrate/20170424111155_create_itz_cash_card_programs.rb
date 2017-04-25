class CreateItzCashCardPrograms < ActiveRecord::Migration
  def change
    create_table :itz_cash_card_programs do |t|
      t.string :product_code
      t.string :charge_code
      t.string :name

      t.timestamps null: false
    end

    # also adding itzcash card program reference to cards
    add_column :cards, :itz_cash_card_program_id, :integer, references: "ItzCashCardProgram", foreign_key: true, index: true
  end
end