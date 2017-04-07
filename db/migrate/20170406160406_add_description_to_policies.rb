class AddDescriptionToPolicies < ActiveRecord::Migration
  def change
    add_column :policies, :description, :text
  end
end
