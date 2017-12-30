class AddDefaultToRetryCountInPayments < ActiveRecord::Migration
  def change
    change_column :payments, :retry_count, :integer, default: 0
  end
end
