class ExportRequest < ApplicationRecord
  belongs_to :user
  belongs_to :company
  belongs_to :export_template


  has_attached_file :file
  do_not_validate_attachment_file_type :file
end
