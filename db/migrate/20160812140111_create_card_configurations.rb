class CreateCardConfigurations < ActiveRecord::Migration[4.2]
  def change
    create_table :card_configurations do |t|
      t.integer :prepaid_card_id, references: 'user', index: true, foreign_key: true
      t.integer :configured_by_user_id, references: 'user', index: true, foreign_key: true
      t.references :card_status, index: true, foreign_key: true
      t.datetime :end_date

      t.timestamps null: false
    end
  end
end
