class AddVacationDelegateEnabledToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :vacation_delegate_enabled, :boolean
  end
end
