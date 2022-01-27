class CreateEmailApproval < ActiveRecord::Migration[6.0]
  def change
    create_table :email_approvals do |t|
      t.string :approval_uuid
      t.integer :email_approval_status_id
      t.datetime :deleted_at
      t.integer :company_id
      t.references :documentable, polymorphic: true
      t.timestamps
    end

    add_index :email_approvals, :approval_uuid
  end
end
