class AddPointOfContactToUsers < ActiveRecord::Migration
  def change
    add_column :users, :point_of_contact, :boolean
    remove_column :users, :quickbooks_id, :integer
    remove_column :users, :quickbooks_additional_information, :text
    remove_column :users, :quickbooks_integration_type, :string
    remove_column :users, :quickbooks_updated_at, :datetime
  end
end
