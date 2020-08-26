# == Schema Information
#
# Table name: custom_field_attachments
#
#  id                      :bigint           not null
#  uuid                    :string(36)       not null, primary key
#  form_custom_field_id    :string(255)
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  attachment_file_size    :bigint
#  attachment_updated_at   :datetime
#  deleted_at              :datetime
#

class CustomFieldAttachment < ApplicationRecord

  include SoftDeletable, UUIDHelper

  include Attachable

  belongs_to :form_custom_field

  CONTENT_TYPES = {content_type: []}

  has_attached_file :attachment, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :attachment, content_type: CONTENT_TYPES
end
