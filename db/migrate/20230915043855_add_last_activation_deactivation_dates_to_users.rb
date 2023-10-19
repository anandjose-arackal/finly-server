class AddLastActivationDeactivationDatesToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :last_activated_at, :datetime
    add_column :users, :last_deactivated_at, :datetime
  end
end
