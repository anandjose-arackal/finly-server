class CreateMasterEntityChoices < ActiveRecord::Migration[5.2]
  def change
    create_table :master_entity_choices do |t|
      t.uuid
      t.integer :company_id, index: true, foreign_key: true, null: false, references: 'companies'
      t.string :name, index: true, null: false
      t.integer :position, index: true
      t.string :master_entity_id, index: true, null: false
      t.integer :created_by_id, index: true, foreign_key: true, references: 'users'
      t.datetime :deleted_at, index: true

      t.timestamps index: true, null: false
    end
  end
end
