class CreateInvoiceReminders < ActiveRecord::Migration[4.2]
  def change
    create_table :invoice_reminders do |t|
      t.integer :days
      t.integer :reference_date_type
      t.string :timeframe_type
      t.references :company

      t.timestamps null: false
    end
  end
end