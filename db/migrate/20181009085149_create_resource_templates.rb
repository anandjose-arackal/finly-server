class CreateResourceTemplates < ActiveRecord::Migration[4.2]
  def change
    create_table :resource_templates do |t|
      t.string :name, null: false, index: true
      t.string :resource_type, null: false, index: true
      t.references :user, index: true, null: false, foreign_key: true
      t.datetime :last_used_at

      t.timestamps null: false
    end
    add_column :purchase_orders, :resource_template_id, :integer, references: 'ResourceTemplate', index: true, foreign_key: true
    add_column :invoices,:resource_template_id, :integer, references: 'ResourceTemplate', index: true, foreign_key: true
  end
end
