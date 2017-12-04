class AllowNilForInitiatingUserInPayments < ActiveRecord::Migration
  def change
    change_column_null :payments, :initiating_user_id, true
    change_column_null :payments, :initiating_user_type, true
    change_column_null :payments, :receiving_user_id, true
    change_column_null :payments, :receiving_user_type, true
  end
end
