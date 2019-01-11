class CreateReports < ActiveRecord::Migration[4.2]
  def change
    create_table :reports do |t|
      t.string :name, null: false
      t.references :user, index: true, foreign_key: true, null: false
      t.references :report_status, index: true, foreign_key: true, null: false
      t.references :policy, index: true, foreign_key: true
      t.datetime :submitted_at, limit: 6
      t.integer :controlling_user_id,:references => "user", index: true, foreign_key: true
      t.integer :controlling_user_role_id, :references => "user_role", index: true, foreign_key: true
      t.integer :controlling_for_user_id,:references => "user", index: true, foreign_key: true
      t.integer :controlling_for_user_role_id, :references => "user_role", index: true, foreign_key: true
      t.string :memo

      t.timestamps null: false
    end
  end
end
