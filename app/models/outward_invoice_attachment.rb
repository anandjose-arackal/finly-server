# == Schema Information
#
# Table name: outward_invoice_attachments
#
#  id                      :integer          not null, primary key
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#  outward_invoice_id      :integer
#  description             :text(65535)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  company_id              :integer
#  user_id                 :integer
#

class OutwardInvoiceAttachment < ApplicationRecord
  include Attachable

  belongs_to :outward_invoice, optional: true

  CONTENT_TYPES = {content_type: []}

  has_attached_file :attachment, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :attachment, content_type: CONTENT_TYPES

  scope :with_id, -> (ids) { where id: ids }
end
