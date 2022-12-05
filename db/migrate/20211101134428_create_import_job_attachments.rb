class CreateImportJobAttachments < ActiveRecord::Migration[6.0]
  def change
    create_table :import_job_attachments do |t|
      t.uuid
      t.string :import_job_id, index: true, references: 'import_jobs', null: false, foreign_key: true
      t.integer :created_by_id, index: true, references: 'users'
      t.references :company, index: true, null: false
      t.attachment :attachment
      t.datetime :deleted_at, index: true

      t.timestamps null: false, index: true
    end
  end
end
