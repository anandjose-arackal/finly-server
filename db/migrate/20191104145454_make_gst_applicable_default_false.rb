class MakeGstApplicableDefaultFalse < ActiveRecord::Migration[5.2]
  def change
    change_column :categories, :gst_applicable, :boolean, default: false
  end
end
