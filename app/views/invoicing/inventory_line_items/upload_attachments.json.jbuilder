json.extract! @result.artifact, :id, :description
json.file_name @result.artifact.attachment_file_name
json.file_size (@result.artifact.attachment_file_size / 1024).round(2).to_s + " KB"
json.url @result.artifact.attachment.url