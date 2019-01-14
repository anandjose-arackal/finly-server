class ChangeColumnNullForReceivingUserInPayments < ActiveRecord::Migration[4.2]
  def change
    change_column_null :payments, :receiving_user_id, true
  end
end
