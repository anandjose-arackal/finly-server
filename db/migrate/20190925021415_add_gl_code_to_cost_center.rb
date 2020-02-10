class AddGlCodeToCostCenter < ActiveRecord::Migration[5.2]
  def change
    add_column :cost_centers, :gl_code, :string
    add_column :departments, :gl_code, :string
    add_column :branch_locations, :gl_code, :string
  end
end
