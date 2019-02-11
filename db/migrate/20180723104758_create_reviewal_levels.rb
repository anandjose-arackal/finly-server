class CreateReviewalLevels < ActiveRecord::Migration[4.2]
  def change
    create_table :reviewal_levels do |t|
      t.integer :level_number
      t.references :policy, index: true, foreign_key: true
      t.string :associated_entity_type

      t.timestamps null: false
    end
  end
end
