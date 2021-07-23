class AddHasNestingToMasterSchema < ActiveRecord::Migration[6.0]
  def change
    add_column :master_schemas, :has_nesting, :boolean, default: false
    add_column :master_schemas, :can_nesting_be_changed, :boolean
  end
end
