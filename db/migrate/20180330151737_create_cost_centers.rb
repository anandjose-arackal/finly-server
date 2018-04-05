class CreateCostCenters < ActiveRecord::Migration
  def change
    create_table :cost_centers do |t|
      t.string :name
      t.string :application
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
