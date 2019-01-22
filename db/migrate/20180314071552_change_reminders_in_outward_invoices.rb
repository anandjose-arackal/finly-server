class ChangeRemindersInOutwardInvoices < ActiveRecord::Migration[4.2]
  def up
    change_column :outward_invoices, :reminders, :text
  end

  def down
    change_column :outward_invoices, :reminders, :integer
  end
end
