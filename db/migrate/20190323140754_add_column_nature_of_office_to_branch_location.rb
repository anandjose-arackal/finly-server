class AddColumnNatureOfOfficeToBranchLocation < ActiveRecord::Migration[5.2]
  def change
    add_column :branch_locations, :nature_of_office, :string
  end
end
