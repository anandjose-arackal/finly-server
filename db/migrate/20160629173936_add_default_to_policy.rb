class AddDefaultToPolicy < ActiveRecord::Migration[4.2]
  def change
    add_column :policies, :default, :boolean, null: false, default: false
  end
end
