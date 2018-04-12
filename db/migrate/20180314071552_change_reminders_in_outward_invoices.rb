class ChangeRemindersInOutwardInvoices < ActiveRecord::Migration
  def up
    change_column :outward_invoices, :reminders, :text
  end

  def down
    change_column :outward_invoices, :reminders, :integer
  end
end
