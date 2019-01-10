class AddDefaultToRetryCountInPayments < ActiveRecord::Migration[4.2]
  def change
    change_column :payments, :retry_count, :integer, default: 0
  end
end
