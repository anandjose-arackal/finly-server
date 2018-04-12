class ChangeReferenceDateTypeInReminders < ActiveRecord::Migration
  def change
    change_column :invoice_reminders, :reference_date_type, :string
  end
end
