json.array! @result.attachments do |attachment|
  json.extract! attachment, :id, :name, :description

  json.file_name attachment.file.original_filename
  json.file_size (attachment.file_file_size / 1024).round(2).to_s + " KB"
  json.url attachment.file.url
end