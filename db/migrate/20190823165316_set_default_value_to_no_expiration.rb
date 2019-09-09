class SetDefaultValueToNoExpiration < ActiveRecord::Migration[5.2]
  def change
    change_column_null :payment_agreements, :no_expiration, false, false
  end
end
