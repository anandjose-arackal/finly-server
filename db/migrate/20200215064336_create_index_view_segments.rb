class CreateIndexViewSegments < ActiveRecord::Migration[5.2]
  def change
    create_table :index_view_segments do |t|
      t.uuid
      t.string :screen, index: true, null: false
      t.string :name, index: true, null: false
      t.text :filters
      t.text :columns
      t.boolean :system_view, default: false, index: true
      t.integer :company_id, foreign_key: true, index: true, references: 'companies'
      t.integer :user_id, foreign_key: true, index: true, references: 'users'
      t.datetime :last_viewed_at, index: true
      t.datetime :deleted_at, index: true

      t.timestamps null: false
    end
  end
end
