class AddIndexToAmounts < ActiveRecord::Migration[5.2]
  def change
  	add_index :amounts, :created_at
  end
end
