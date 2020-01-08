class CreateInsightDashboards < ActiveRecord::Migration[5.2]
  def change
    create_table :insight_dashboards do |t|
      t.uuid :uuid
      t.references :company, foreign_key: true, index: true, type: :integer
      t.references :user, foreign_key: true, index: true, type: :integer
      t.references :policy, foreign_key: true, index: true, type: :integer
      t.references :user_role, foreign_key: true, index: true, type: :integer
      t.string :application, null: false, index: true
      t.integer :dashboard, index: true, null: false
      t.string :name, index: true
      t.text :description
      t.string :app, index: true
      t.integer :admin_user_id, references: 'admin_users', index: true, foreign_key: true
      t.integer :priority, index: true, default: 1
      t.datetime :deleted_at, index: true
      t.boolean :active, index: true, default: true

      t.timestamps index: true, null: false
    end

  end
end
