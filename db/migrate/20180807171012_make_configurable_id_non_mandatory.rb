class MakeConfigurableIdNonMandatory < ActiveRecord::Migration
  def change
    ActiveRecord::Migration.change_column_null :field_configurations, :configurable_id, true
  end
end
