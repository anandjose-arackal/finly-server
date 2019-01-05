class AddNameToInvoiceReminders < ActiveRecord::Migration[4.2]
  def change
    add_column :invoice_reminders, :name, :string
  end
end
