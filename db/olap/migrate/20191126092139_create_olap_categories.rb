class CreateOlapCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :olap_dimensions_categories do |t|
      t.integer :finly_ref_id, index: true, null: false, :limit => 8
      t.string :name, index: true
      t.string :gl_code, index: true
      t.boolean :active, index: true

      t.timestamps index: true
    end
  end
end
