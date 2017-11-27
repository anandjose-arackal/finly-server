class CreateTallyConfigurations < ActiveRecord::Migration
  def change
    create_table :tally_configurations do |t|
      t.references :company, index: true, foreign_key: true, null: false
      t.string :company_name
      t.boolean :active

      t.timestamps null: false
    end
  end
end
