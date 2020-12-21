class CreateVersionAssociation < ActiveRecord::Migration[5.2]
  def change
    add_column :version_associations, :foreign_type, :string
  end
end
