# == Schema Information
#
# Table name: receipt_emails
#
#  id          :integer          not null, primary key
#  subject     :string(255)
#  body        :text(65535)
#  raw_text    :text(65535)
#  raw_html    :text(65535)
#  raw_headers :text(65535)
#  sent_at     :datetime
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#


class ReceiptEmail < ActiveRecord::Base
  has_many :receipts
  has_many :receipt_email_attachments
  belongs_to :user

  validates :user_id, presence: true

  def save_receipt_image
    if receipt_email_attachments.any?
      receipt_email_attachments.each do |email_attachment|
        image_tmp_path = "#{Rails.root}/tmp/pdfs/#{email_attachment.original_attachment_file_name}".gsub(/\..*$/, '.jpg')
        document_converter = ReceiptProcessor::BaseConverter.new  email_attachment.original_attachment.path,
                                                                  email_attachment.original_attachment_content_type,
                                                                  image_tmp_path
        document_converter.convert do |images|
          images.each { |image| receipts.create(user_id: user_id, image: image) }
        end
      end
    else
      image_tmp_path = "#{Rails.root}/tmp/html_to_image/#{id}.jpg"
      document_converter = ReceiptProcessor::BaseConverter.new  raw_html,
                                                                ReceiptProcessor::BaseConverter::HTML_CONTENT_TYPES.first,
                                                                image_tmp_path
      document_converter.convert do |images|
        images.each { |image| receipts.create(user_id: user_id, image: image) }
      end
    end
  end
end
