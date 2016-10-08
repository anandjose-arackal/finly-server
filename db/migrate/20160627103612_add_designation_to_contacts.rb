class AddDesignationToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :contactable_id, :integer, index: true
    add_column :contacts, :contactable_type, :string
    add_column :contacts, :designation, :string
  end
end