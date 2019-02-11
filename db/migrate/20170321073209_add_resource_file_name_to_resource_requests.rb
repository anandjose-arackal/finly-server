class AddResourceFileNameToResourceRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :resource_requests, :resource_file_name, :string
  end
end
