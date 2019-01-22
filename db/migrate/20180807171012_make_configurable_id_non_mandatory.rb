class MakeConfigurableIdNonMandatory < ActiveRecord::Migration[4.2]
  def change
    ActiveRecord::Migration[4.2].change_column_null :field_configurations, :configurable_id, true
  end
end
