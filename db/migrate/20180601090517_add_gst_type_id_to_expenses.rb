class AddGstTypeIdToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :gst_type_id, :integer
    add_column :expenses, :tds_slab_id, :integer, references: 'TdsRatesList', foreign_key: true, index: true
  end
end
