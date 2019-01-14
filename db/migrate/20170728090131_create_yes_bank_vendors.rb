class CreateYesBankVendors < ActiveRecord::Migration[4.2]
  def change
    create_table :yes_bank_vendors do |t|
      t.string :name
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
