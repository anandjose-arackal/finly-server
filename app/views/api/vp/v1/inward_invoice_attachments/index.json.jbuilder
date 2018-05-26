json.array!(@result.invoice_attachments) do |invoice_attachment|
  json.description invoice_attachment.description

  json.url invoice_attachment.attached_file&.url
  json.thumb invoice_attachment.attached_file&.url(:thumb)
  json.content_type invoice_attachment.attached_file&.content_type
  json.file_name invoice_attachment.attached_file&.original_filename
end