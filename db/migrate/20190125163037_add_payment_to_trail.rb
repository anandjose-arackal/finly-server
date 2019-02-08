class AddPaymentToTrail < ActiveRecord::Migration[5.2]
  def change
    add_column :trails, :payment_id, :integer, foreign_key: true, index: true
  end
end
