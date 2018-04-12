class AddRemindersToInvoices < ActiveRecord::Migration
  def change
    add_column :outward_invoices, :reminders, :integer
  end
end
