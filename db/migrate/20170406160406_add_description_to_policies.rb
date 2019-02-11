class AddDescriptionToPolicies < ActiveRecord::Migration[4.2]
  def change
    add_column :policies, :description, :text
  end
end
