class CreateTaxRates < ActiveRecord::Migration[4.2]
  def change
    create_table :tax_rates do |t|
      t.string :name
      t.decimal :rate, :precision => 20, :scale => 5
      t.string :internal_id
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
