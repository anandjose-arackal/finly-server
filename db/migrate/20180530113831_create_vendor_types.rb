class CreateVendorTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :vendor_types do |t|
      t.string :name
      t.text :description
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_reference :yes_bank_vendors, :vendor_type, index: true, foreign_key: true
  end
end
