class CreateInvoiceNumberConfigTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :invoice_number_config_types do |t|
      t.string :name

      t.timestamps null: false
    end

    InvoiceNumberConfigType.seed_data
  end
end
