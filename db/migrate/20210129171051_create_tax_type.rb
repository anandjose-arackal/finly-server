class CreateTaxType < ActiveRecord::Migration[6.0]
  def change
    create_table :tax_types do |t|
      t.string :country_name, default: ""
      t.string :name, default: ""
      t.string :tax_name, default: ""
      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
    TaxType.seed_data
  end
end
