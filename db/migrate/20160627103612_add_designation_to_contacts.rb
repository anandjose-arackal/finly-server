class AddDesignationToContacts < ActiveRecord::Migration[4.2]
  def change
    add_column :contacts, :contactable_id, :integer, index: true
    add_column :contacts, :contactable_type, :string
    add_column :contacts, :designation, :string
  end
end