class ChangeReferenceDateTypeInReminders < ActiveRecord::Migration[4.2]
  def change
    change_column :invoice_reminders, :reference_date_type, :string
  end
end
