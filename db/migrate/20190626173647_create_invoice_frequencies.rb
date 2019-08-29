class CreateInvoiceFrequencies < ActiveRecord::Migration[5.2]
  def change
    create_table :invoice_frequencies do |t|
      t.integer :number
      t.integer :period_id

      t.timestamps
    end
    add_index :invoice_frequencies, :period_id
  end
end
