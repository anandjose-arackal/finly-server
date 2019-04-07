class Attachment < ApplicationRecord
  include Attachable

  belongs_to :resource, optional: true, polymorphic: true
  belongs_to :creator, optional: true, class_name: "User"
  belongs_to :company, optional: true

  CONTENT_TYPES = {content_type: []}

  has_attached_file :file, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :file, content_type: CONTENT_TYPES

  scope :orphans, -> {
    where(resource_id: nil)
  }


  def as_json
    {
      id: self.id,
      name: self.file_file_name,
      url: self.file&.url,
      created_at: self.created_at.to_date,
      resource_type: self.resource_type,
      resource_id: self.resource_id,
      file_name: self.file.original_filename,
      file_size: (self.file_file_size / 1024).round(2).to_s + " KB"
      # created_by: self.creator&.name,
      # description: self.description
    }
  end
end
