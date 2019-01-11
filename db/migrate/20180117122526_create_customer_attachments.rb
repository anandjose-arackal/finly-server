class CreateCustomerAttachments < ActiveRecord::Migration[4.2]
  def change
    create_table :customer_attachments do |t|
      t.attachment :attached_file
      t.references :customer, index: true, foreign_key: true
      t.text :note

      t.timestamps null: false
    end

    add_column :addresses, :default, :boolean
    add_column :addresses, :parent_type, :string, polymorphic: true
    add_column :addresses, :parent_id, :integer, polymorphic: true
  end
end
