class CreateMappingPurposes < ActiveRecord::Migration[4.2]
  def change
    create_table :mapping_purposes do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
