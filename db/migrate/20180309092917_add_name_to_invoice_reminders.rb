class AddNameToInvoiceReminders < ActiveRecord::Migration
  def change
    add_column :invoice_reminders, :name, :string
  end
end
