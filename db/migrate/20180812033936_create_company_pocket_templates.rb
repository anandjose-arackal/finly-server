class CreateCompanyPocketTemplates < ActiveRecord::Migration[4.2]
  def change
    create_table :company_pocket_templates do |t|
      t.string :name
      t.references :company, index: true, foreign_key: true
      t.references :user_pocket_type, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end