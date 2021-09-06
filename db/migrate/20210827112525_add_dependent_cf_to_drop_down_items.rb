class AddDependentCfToDropDownItems < ActiveRecord::Migration[6.0]
  def change
    add_column :field_drop_down_items, :has_dependent_cf, :boolean, default: false
    add_column :field_configurations, :has_dependent_cf,:boolean, default: false
  end
end