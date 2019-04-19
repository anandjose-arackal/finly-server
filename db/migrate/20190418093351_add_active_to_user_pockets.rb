class AddActiveToUserPockets < ActiveRecord::Migration[5.2]
  def change
    add_column :user_pockets, :active, :boolean, default: true
  end
end
