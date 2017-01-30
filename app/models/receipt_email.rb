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

require 'fileutils'
class ReceiptEmail < ActiveRecord::Base
  has_many :receipts
  has_many :receipt_email_attachments
  belongs_to :user

  validates :user_id, presence: true

  def save_receipt_image
    FileUtils.mkdir_p "#{Rails.root}/tmp/images"

      if receipt_email_attachments.any?
        receipt_email_attachments.each do |email_attachment|
          image_tmp_path = "#{Rails.root}/tmp/images/#{email_attachment.original_attachment_file_name}".gsub(/\..*$/, '.jpg')
          document_converter = ReceiptProcessor::BaseConverter.new  email_attachment.original_attachment.path,
                                                                    email_attachment.original_attachment_content_type,
                                                                    image_tmp_path
          document_converter.convert do |images|
            images.each { |image| receipts.create(user_id: user_id, image: image, note: self.subject) }
          end
        end
      else
        image_tmp_path = "#{Rails.root}/tmp/images/#{id}.jpg"
        document_converter = ReceiptProcessor::BaseConverter.new  raw_html,
                                                                  ReceiptProcessor::BaseConverter::HTML_CONTENT_TYPES.first,
                                                                  image_tmp_path
        document_converter.convert do |images|
          images.each { |image| receipts.create(user_id: user_id, image: image, note: self.subject) }
        end
      end
  end
end
