class CreateDummyRestrictions < ActiveRecord::Migration
  def change
    create_table :card_restrictions do |t|
      t.references :user, index: true, foreign_key: true
      t.boolean :channel_atm
      t.boolean :channel_pos
      t.boolean :channel_online
      t.integer :product_code_id, references: "ProductCombination", index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
