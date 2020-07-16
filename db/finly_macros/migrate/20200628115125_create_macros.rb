class CreateMacros < ActiveRecord::Migration[6.0]
  def change
    create_table :macros do |t|
      t.string :macro_id, index: true, null: false
      t.string :name, index: true, null: false
      t.text :description
      t.text :script, null: false
      t.integer :macro_type_id, index: true, null: false
      t.boolean :active, index: true
      t.date :start_date, index: true
      t.date :end_date, index: true
      t.integer :company_id, index: true
      t.integer :user_id, index: true, null: false
      t.integer :created_by_id, index: true
      t.integer :created_by_admin_id, index: true
      t.boolean :long_running_job, index: true
      t.datetime :last_run_at, index: true
      t.datetime :deleted_at, index: true

      t.timestamps index: true
    end
  end
end
