class ChangeColumnNullForReceivingUserInPayments < ActiveRecord::Migration
  def change
    change_column_null :payments, :receiving_user_id, true
  end
end
