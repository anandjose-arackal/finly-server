class ReceiptEmailStatusSeedData < ActiveRecord::Migration[5.2]
  def change
    ::ReceiptEmailStatus.seed_data
  end
end
