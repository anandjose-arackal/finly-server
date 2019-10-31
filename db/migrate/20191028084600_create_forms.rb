class CreateForms < ActiveRecord::Migration[5.2]
  def change
    create_table :forms do |t|
      t.string :uuid, index: true, limit: 36, null: false
      t.string :klass_name, index: true, null: false
      t.string :model, index: true, null: false
      t.integer :company_id, index: true, null: false, foreign_key: true, references: 'companies'

      t.datetime :deleted_at, index: true
      t.timestamps index: true
    end
  end
end
