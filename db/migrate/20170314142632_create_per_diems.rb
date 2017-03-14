class CreatePerDiems < ActiveRecord::Migration
  def change
    create_table :per_diems do |t|
      t.string :name
      t.integer :rate_id, references: "Amount", foreign_key: true, index: true
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
