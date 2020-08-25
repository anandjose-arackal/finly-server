class CustomFieldAttachment < ApplicationRecord

  include SoftDeletable, UUIDHelper

  include Attachable

  belongs_to :form_custom_field

  CONTENT_TYPES = {content_type: []}

  has_attached_file :attachment, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :attachment, content_type: CONTENT_TYPES
end
