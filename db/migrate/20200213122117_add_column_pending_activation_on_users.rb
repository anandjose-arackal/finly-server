class AddColumnPendingActivationOnUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :pending_activation, :boolean, default: false
  end
end
