class CreateUniqueIdentifiers < ActiveRecord::Migration[4.2]
  def change
    create_table :unique_identifiers do |t|
      t.string :prefix, null: false
      t.string :sequence_start, null: false
      t.references :purpose, index: true, foreign_key: true, null: false
      t.references :company, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
