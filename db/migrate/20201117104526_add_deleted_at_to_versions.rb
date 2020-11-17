class AddDeletedAtToVersions < ActiveRecord::Migration[6.0]
  def change
    add_column :versions, :deleted_at, :timestampapp/procedures/index_builder/show.rb
  end
end
