class AddSourceAndSourceDescriptionToDemoRequests < ActiveRecord::Migration
  def change
    unless PreviewRegistration.column_names.include?('source')
      add_column :preview_registrations, :source, :text
      add_column :preview_registrations, :source_description, :text
    end
    unless ResourceRequest.column_names.include?('source')
      add_column :resource_requests, :source, :text
      add_column :resource_requests, :source_description, :text
    end
  end
end
