# == Schema Information
#
# Table name: procurement_attachments
#
#  id                        :integer          not null, primary key
#  file_file_name            :string(255)
#  file_content_type         :string(255)
#  file_file_size            :integer
#  file_updated_at           :datetime
#  name                      :string(255)
#  company_id                :integer
#  description               :text(65535)
#  procurement_document_id   :integer
#  procurement_document_type :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  user_id                   :integer
#  vendor_poc_id             :integer
#  deleted_at                :datetime
#

class ProcurementAttachment < ApplicationRecord
  include Attachable
  include ActiveStorageSync
  belongs_to :procurement_document, optional: true, polymorphic: true
  belongs_to :company, optional: true
  belongs_to :user, optional: true

  CONTENT_TYPES = {content_type: []}

  has_attached_file :file, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :file, content_type: CONTENT_TYPES

  scope :orphans, -> {
    where(procurement_document: nil)
  }

  scope :with_id, -> (ids) { where id: ids }

  def as_json
    {
      id: id,
      description: description,
      file_name: file_file_name,
      file_size: file_size,
      url: file&.url(:original, timestamp: false),
      content_type: file_content_type
    }
  end

  def file_format
    if self.file_content_type == 'application/pdf'
      type = "pdf"
    elsif ["image/jpg", "image/jpeg", "image/png", "image/gif"].include?(self.file_content_type)
      type = "image"
    else
      type = "other"
    end
    type
  end

  private

  def file_size
    f_size = file_file_size.to_f
    (f_size / 1024).round(2).to_s + " KB"
  end
end
