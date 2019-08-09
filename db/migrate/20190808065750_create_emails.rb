class CreateEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :emails do |t|
      t.references :entity, polymorphic: true
      t.integer :company_id, index: true#, null: false
      # t.integer :user_id, index: true#, null: false
      t.string :message_id, index: true
      t.string :sender, index: true
      t.string :recipient, index: true
      t.string :bcc, index: true
      t.string :cc, index: true
      t.string :subject, index: true
      t.text :body, limit: 4294967295
      t.string :mailer_klass, index: true
      t.string :mailer_action, index: true
      t.string :configuration_set
      t.datetime :sent_at, index: true
      t.datetime :delivered_at, index: true
      t.integer :delivery_count, index: true
      t.datetime :last_opened_at, index: true
      t.integer :open_count, index: true
      t.datetime :last_link_clicked_at, index: true
      t.integer :link_open_count, index: true

      t.timestamps
    end
  end
end
