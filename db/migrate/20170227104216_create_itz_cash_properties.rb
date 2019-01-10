class CreateItzCashProperties < ActiveRecord::Migration[4.2]
  def change
    remove_column :companies, :d_code
    create_table :itz_cash_properties do |t|
      t.string :d_code
      t.string :easy_account_no
      t.references :company, null: false, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
