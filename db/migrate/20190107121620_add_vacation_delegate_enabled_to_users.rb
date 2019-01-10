class AddVacationDelegateEnabledToUsers < ActiveRecord::Migration
  def change
    add_column :users, :vacation_delegate_enabled, :boolean
  end
end
