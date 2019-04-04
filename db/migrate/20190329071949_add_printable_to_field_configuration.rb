class AddPrintableToFieldConfiguration < ActiveRecord::Migration[5.2]
  def change
    add_column :field_configurations, :printable, :boolean, default: true
  end
end
