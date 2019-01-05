class AddRemindersToInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :outward_invoices, :reminders, :integer
  end
end
