class AddGstEnabledAsTrueByDefaultForCategories < ActiveRecord::Migration[5.2]
  def change
    change_column :categories, :gst_applicable, :boolean, default: true
    Category.all.update_all(gst_applicable: true)
  end
end
