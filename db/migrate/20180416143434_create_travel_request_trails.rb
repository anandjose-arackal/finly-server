class CreateTravelRequestTrails < ActiveRecord::Migration[4.2]
  def change
    create_table :travel_request_trails do |t|
      t.references :travel_request, index: true, foreign_key: true
      t.integer :action_id, references: "TravelRequestTrailAction", foreign_key: true, index: true
      t.integer :action_user_id, references: "User", foreign_key: true, index: true
      t.integer :action_user_role_id, references: "UserRole", foreign_key: true, index: true
      t.integer :modified_user_id, references: "User", foreign_key: true, index: true
      t.integer :modified_user_role_id, references: "UserRole", foreign_key: true, index: true
      t.integer :action_for_user_id, references: "User", foreign_key: true, index: true
      t.integer :action_for_user_role_id, references: "UserRole", foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
