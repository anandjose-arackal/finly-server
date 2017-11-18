class AddPurposeToPolicies < ActiveRecord::Migration
  def change
    add_column :policies, :application, :string
  end
end
