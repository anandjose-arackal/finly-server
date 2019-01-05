# == Schema Information
#
# Table name: invoice_attachments
#
#  id                         :integer          not null, primary key
#  attached_file_file_name    :string(255)
#  attached_file_content_type :string(255)
#  attached_file_file_size    :integer
#  attached_file_updated_at   :datetime
#  invoice_id                 :integer
#  description                :text(65535)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  company_id                 :integer
#

class InvoiceAttachment < ApplicationRecord
  include Attachable

  belongs_to :invoice, optional: true
  belongs_to :company, optional: true

  # CONTENT_TYPES = {content_type: %w(image/jpg image/jpeg image/png image/gif application/pdf application/rtf)}

  CONTENT_TYPES = {content_type: []}

  has_attached_file :attached_file, styles: lambda { |a| a.instance.style_format(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :attached_file, content_type: CONTENT_TYPES

  scope :without_parent, -> { where invoice_id: nil }
end