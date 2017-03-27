class AddResourceFileNameToResourceRequests < ActiveRecord::Migration
  def change
    add_column :resource_requests, :resource_file_name, :string
  end
end
