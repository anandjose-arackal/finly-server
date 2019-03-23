# == Schema Information
#
# Table name: vendor_attachments
#
#  id                         :integer          not null, primary key
#  attached_file_file_name    :string(255)
#  attached_file_content_type :string(255)
#  attached_file_file_size    :integer
#  attached_file_updated_at   :datetime
#  description                :text(65535)
#  yes_bank_vendor_id         :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  attachment_type            :string(255)
#

class VendorAttachment < ApplicationRecord

  # Attachment Types: [:pan, gstin, cancelled_cheque]

  belongs_to :yes_bank_vendor, optional: true

  include Attachable

  CONTENT_TYPES = {content_type: %w(image/jpg image/jpeg image/png image/gif application/pdf application/rtf)}

  # has_attached_file :attached_file, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  has_attached_file :attached_file, default_url: '/assets/:style/missing.png'
  validates_attachment :attached_file, content_type: CONTENT_TYPES

  scope :pan_attachment, -> { where attachment_type: 'pan' }
  scope :gstin_attachment, -> { where attachment_type: 'gstin' }
  scope :cancelled_cheque_attachment, -> { where attachment_type: 'cancelled_cheque' }
  scope :no_type_attachments, -> {where attachment_type: nil}
end
