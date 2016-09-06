class ReceiptEmailAttachment < ActiveRecord::Base
  PDF_CONTENT_TYPES = ['application/pdf'].freeze
  IMAGE_CONTENT_TYPES = ['image/jpg', 'image/jpeg', 'image/png', 'image/gif'].freeze
  MSWORD_CONTENT_TYPES = ['application/rtf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'].freeze

  belongs_to :receipt_email
  has_attached_file :original_attachment

  validates_attachment  :original_attachment,
                        presence: true,
                        content_type: {
                            content_type: (IMAGE_CONTENT_TYPES + PDF_CONTENT_TYPES + MSWORD_CONTENT_TYPES)
                        }

  scope :pdfs, -> { where(original_attachment_content_type: PDF_CONTENT_TYPES) }
  scope :images, -> { where(original_attachment_content_type: IMAGE_CONTENT_TYPES) }
  scope :msdoc, -> { where(original_attachment_content_type: MSWORD_CONTENT_TYPES) }

  def pdf?
    PDF_CONTENT_TYPES.include? original_attachment_content_type
  end

  def image?
    IMAGE_CONTENT_TYPES.include? original_attachment_content_type
  end

  def msdoc?
    MSWORD_CONTENT_TYPES.include? original_attachment_content_type
  end
end
