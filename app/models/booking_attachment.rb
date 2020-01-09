# == Schema Information
#
# Table name: booking_attachments
#
#  id                      :integer          not null, primary key
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#  booking_id              :integer
#  user_id                 :integer
#  company_id              :integer
#  description             :text(65535)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class BookingAttachment < ApplicationRecord
  include Attachable

  belongs_to :booking, optional: true
  belongs_to :user, optional: true
  belongs_to :company, optional: true

  CONTENT_TYPES = {content_type: []}

  has_attached_file :attachment, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :attachment, content_type: CONTENT_TYPES

  scope :with_id, -> (ids) { where id: ids }

  def file_format
    if self.attachment_content_type == 'application/pdf'
      type = "pdf"
    elsif ["image/jpg", "image/jpeg", "image/png", "image/gif"].include?(self.attachment_content_type)
      type = "image"
    else
      type = ''
    end
    type
  end

  def as_json(options={})
    {
        id: id,
        image: {
            file_type: file_format,
            original: attachment.url,
            thumb: attachment.url(:thumb)
        }
    }
  end

end
