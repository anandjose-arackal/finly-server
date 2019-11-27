class CreateOlapCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :olap_dimensions_categories do |t|
      t.olap_references
      t.string :name, index: true
      t.string :gl_code, index: true
      t.boolean :active, index: true

      t.timestamps index: true
    end
  end
end
