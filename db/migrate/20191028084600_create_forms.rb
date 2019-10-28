class CreateForms < ActiveRecord::Migration[5.2]
  def change
    create_table :forms do |t|
      t.string :uuid, index: true, limit: 36, null: false
      t.string :klass_name, index: true, null: false
      t.string :model, index: true, null: false
      t.integer :company_id, references: "Company", foreign_key: true, index: true, null: false

      t.timestamps index: true
    end
  end
end
