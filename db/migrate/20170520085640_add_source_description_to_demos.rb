class AddSourceDescriptionToDemos < ActiveRecord::Migration
  def change
    add_column :preview_registrations, :source_description, :text
    add_column :resource_requests, :source_description, :text
  end
end
