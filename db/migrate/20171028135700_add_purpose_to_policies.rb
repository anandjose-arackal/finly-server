class AddPurposeToPolicies < ActiveRecord::Migration[4.2]
  def change
    add_column :policies, :application, :string
  end
end
