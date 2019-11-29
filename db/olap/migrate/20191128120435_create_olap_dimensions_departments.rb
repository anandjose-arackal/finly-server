class CreateOlapDimensionsDepartments < ActiveRecord::Migration[5.2]
  def change
    create_table :olap_dimensions_departments do |t|
      t.olap_references
      t.string :name, index: true
      t.integer :company_id, index: true
      t.boolean :is_deleted, index: true
      t.string :ancestry, index: true
      t.integer :cost_center_id, index: true
      t.datetime :deleted_at, index: true
      t.string :department_code, index: true
      t.string :code, index: true
      t.string :gl_code, index: true

      t.timestamps index: true
    end
  end
end
