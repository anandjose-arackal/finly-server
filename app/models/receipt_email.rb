# == Schema Information
#
# Table name: receipt_emails
#
#  id                      :integer          not null, primary key
#  subject                 :text(65535)
#  sent_at                 :datetime
#  user_id                 :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  body_file_name          :string(255)
#  body_content_type       :string(255)
#  body_file_size          :integer
#  body_updated_at         :datetime
#  raw_text_file_name      :string(255)
#  raw_text_content_type   :string(255)
#  raw_text_file_size      :integer
#  raw_text_updated_at     :datetime
#  raw_html_file_name      :string(255)
#  raw_html_content_type   :string(255)
#  raw_html_file_size      :integer
#  raw_html_updated_at     :datetime
#  raw_header_file_name    :string(255)
#  raw_header_content_type :string(255)
#  raw_header_file_size    :integer
#  raw_header_updated_at   :datetime
#


require 'fileutils'
class ReceiptEmail < ActiveRecord::Base
  has_many :receipts
  has_many :receipt_email_attachments, dependent: :destroy
  belongs_to :user

  validates :user_id, presence: true

  has_attached_file :body
  validates_attachment  :body
  validates_attachment_content_type :body, :content_type => 'text/plain'
  has_attached_file :raw_text
  validates_attachment  :raw_text
  validates_attachment_content_type :raw_text, :content_type => 'text/plain'
  has_attached_file :raw_html
  validates_attachment  :raw_html
  validates_attachment_content_type :raw_html, :content_type => 'text/plain'
  has_attached_file :raw_header
  validates_attachment  :raw_header
  validates_attachment_content_type :raw_header, :content_type => 'text/plain'

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
        raw_html_text = Paperclip.io_adapters.for(raw_html).read.force_encoding(Encoding::UTF_8)
        document_converter = ReceiptProcessor::BaseConverter.new  raw_html_text,
                                                                  ReceiptProcessor::BaseConverter::HTML_CONTENT_TYPES.first,
                                                                  image_tmp_path
        document_converter.convert do |images|
          images.each { |image| receipts.create(user_id: user_id, image: image, note: self.subject) }
        end
      end
  end

end
