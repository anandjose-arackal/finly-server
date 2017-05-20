class AddSourceToDemoRequests < ActiveRecord::Migration
  def change
    add_column :preview_registrations, :source, :text
    add_column :resource_requests, :source, :text
  end
end
