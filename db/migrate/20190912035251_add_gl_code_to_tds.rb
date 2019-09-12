class AddGlCodeToTds < ActiveRecord::Migration[5.2]
  def change
    add_column :tds_rates_lists, :gl_code, :string
    add_column :tds_rates_lists, :deleted_at, :datetime, index: true
  end
end
