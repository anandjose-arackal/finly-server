class AddGstApplicableToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :gst_applicable, :boolean, default: false
  end
end
