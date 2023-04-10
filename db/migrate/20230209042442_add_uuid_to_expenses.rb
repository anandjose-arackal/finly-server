class AddUuidToExpenses < ActiveRecord::Migration[6.0]
  def change
    add_column :expenses, :uuid_key, :string, { limit: 40, null: true }
    add_index :expenses, :uuid_key, { unique: true }
  end
end
