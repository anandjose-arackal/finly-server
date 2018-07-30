json.extract! @result.attachment, :id, :description
json.file_name @result.attachment.file_file_name
json.file_size (@result.attachment.file_file_size / 1024).round(2).to_s + " KB"
json.url @result.attachment.file.url
