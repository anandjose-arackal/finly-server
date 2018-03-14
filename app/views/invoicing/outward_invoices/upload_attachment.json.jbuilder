json.extract! @result.attachment, :id, :description
json.file_name @result.attachment.attachment_file_name
json.file_size (@result.attachment.attachment_file_size / 1024).round(2).to_s + " KB"
json.url @result.attachment.attachment.url

