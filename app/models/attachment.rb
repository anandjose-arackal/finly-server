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
end
