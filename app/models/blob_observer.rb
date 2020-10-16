class BlobObserver < ActiveRecord::Observer
  observe ActiveStorage::Blob

  def after_save(blob)
    if Rails.env.production?
      file_url = blob.service_url
    else
      file_url = Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)
    end
    blob.update_columns(storage_url: file_url)
  end
end