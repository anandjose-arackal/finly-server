class MakeConfigurableIdNonMandatory < ActiveRecord::Migration
  def change
    change_column_null :field_configurations, :configurable_id, false
  end
end
