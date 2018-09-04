class AddDetailsToBranchLocation < ActiveRecord::Migration
  def change
    add_column :branch_locations, :contact_name, :string
    add_column :branch_locations, :contact_mobile_number, :string

  end
end
