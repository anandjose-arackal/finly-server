class CreateTrails < ActiveRecord::Migration[4.2]
  def change
    create_table :trail_actions do |t|
      t.string :name
    end

    TrailAction.seed_data

    create_table :trails do |t|
      t.references :parent, polymorphic: true, index: true
      t.integer :action_user_id, references: 'User', foreign_key: true, index: true
      t.integer :action_id, references: 'TrailAction', foreign_key: true, index: true
      t.integer :action_user_role_id, references: 'UserRole', foreign_key: true, index: true
      t.integer :action_level_id, references: 'ReviewalLevel', foreign_key: true, index: true
      t.integer :modified_level_id, references: 'ReviewalLevel', foreign_key: true, index: true
      t.text :note
      t.timestamps null: false
    end
  end
end
