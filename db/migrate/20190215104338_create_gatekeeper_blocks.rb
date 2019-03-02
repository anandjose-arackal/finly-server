class CreateGatekeeperBlocks < ActiveRecord::Migration[5.2]
  def change
    create_table :gatekeeper_blocks do |t|
      t.integer :user_id, foreign_key: true, index: true, references: 'users'
      t.integer :company_id, foreign_key: true, index: true, references: 'companies'
      t.text :params
      t.text :headers
      t.string :act
      t.string :premise
      t.string :verdict

      t.timestamps
    end
  end
end