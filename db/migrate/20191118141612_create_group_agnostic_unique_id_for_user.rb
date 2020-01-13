class CreateGroupAgnosticUniqueIdForUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :finly_id, :string, limit: 36, index: true
  end
end
