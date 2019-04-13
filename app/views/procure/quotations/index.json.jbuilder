json.count @result.count
json.quotations do
  json.array! @result.quotations do |quote|
    json.merge! quote.as_json
    json.attachments do
      json.array! quote.attachments do |attachment|
        json.extract! attachment, :id, :description
        json.file_name attachment.file_file_name
        json.file_size (attachment.file_file_size / 1024).round(2).to_s + " KB"
        json.url attachment.file.url(:original, timestamp: false)
      end
    end
  end
end