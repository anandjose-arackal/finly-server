class AddDefaultToPolicy < ActiveRecord::Migration
  def change
    add_column :policies, :default, :boolean, null: false, default: false
  end
end
