class AddUsersToPaymentTrails < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_trails, :initiating_user_id, :integer
    add_column :payment_trails, :initiating_user_type, :string
    add_column :payment_trails, :receiving_user_id, :integer
    add_column :payment_trails, :receiving_user_type, :string
  end
end
