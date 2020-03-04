class AddLastRetryTimestampToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :last_retried_at, :datetime
  end
end
