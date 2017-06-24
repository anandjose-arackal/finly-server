# == Schema Information
#
# Table name: receipt_emails
#
#  id                           :integer          not null, primary key
#  subject                      :text(65535)
#  sent_at                      :datetime
#  user_id                      :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  body_file_name               :string(255)
#  body_content_type            :string(255)
#  body_file_size               :integer
#  body_updated_at              :datetime
#  raw_text_file_name           :string(255)
#  raw_text_content_type        :string(255)
#  raw_text_file_size           :integer
#  raw_text_updated_at          :datetime
#  raw_html_file_name           :string(255)
#  raw_html_content_type        :string(255)
#  raw_html_file_size           :integer
#  raw_html_updated_at          :datetime
#  raw_header_file_name         :string(255)
#  raw_header_content_type      :string(255)
#  raw_header_file_size         :integer
#  raw_header_updated_at        :datetime
#  expense_id                   :integer
#  email_id                     :string(255)
#  sender                       :string(255)
#  source                       :string(255)
#  original_source_file_name    :string(255)
#  original_source_content_type :string(255)
#  original_source_file_size    :integer
#  original_source_updated_at   :datetime
#

require 'fileutils'
class ReceiptEmail < ActiveRecord::Base
  has_many :receipts, as: :sourcable
  has_many :receipt_email_attachments, dependent: :destroy
  has_many :expense_data_extracts, as: :extractable
  belongs_to :user
  belongs_to :expense

  accepts_nested_attributes_for :receipt_email_attachments

  default_scope {order expense_id: :desc, created_at: :desc}
  scope :with_email_id, ->(email_id) { where email_id: email_id }

  validates :user_id, presence: true

  # BODY_CONTENT_TYPES = ['text/plain', 'text/html', 'message/rfc822', 'multipart/alternative', 'message/partial']

  has_attached_file :body
  do_not_validate_attachment_file_type :body
  # validates_attachment_content_type :body, :content_type => BODY_CONTENT_TYPES
  has_attached_file :raw_text
  do_not_validate_attachment_file_type :raw_text
  # validates_attachment_content_type :raw_text, :content_type => BODY_CONTENT_TYPES
  has_attached_file :raw_html
  do_not_validate_attachment_file_type :raw_html
  # validates_attachment_content_type :raw_html, :content_type => BODY_CONTENT_TYPES
  has_attached_file :raw_header
  do_not_validate_attachment_file_type :raw_header
  # validates_attachment_content_type :raw_header, :content_type => BODY_CONTENT_TYPES
  has_attached_file :original_source
  do_not_validate_attachment_file_type :original_source

  def save_receipts
    FileUtils.mkdir_p "#{Rails.root}/tmp/images"

    if receipt_email_attachments.any?
      receipt_email_attachments.each do |email_attachment|
        attachment_content_type = email_attachment.original_attachment_content_type
        receipt_files = []
        if ReceiptProcessor::BaseConverter::PDF_CONTENT_TYPES.include? attachment_content_type
          # PDF Attachments
          receipt_files << email_attachment.original_attachment
        elsif ReceiptProcessor::BaseConverter::IMAGE_CONTENT_TYPES.include? attachment_content_type
          # Image Attachments
          receipt_files << email_attachment.original_attachment
        elsif ReceiptProcessor::BaseConverter::HTML_CONTENT_TYPES.include? attachment_content_type
          # HTML Attachments
          image_tmp_path = "#{Rails.root}/tmp/images/#{email_attachment.original_attachment_file_name}".gsub(/\..*$/, '.jpg')
          document_converter = ReceiptProcessor::BaseConverter.new email_attachment.original_attachment.path,
                                                                   email_attachment.original_attachment_content_type,
                                                                   image_tmp_path
          document_converter.convert do |images|
            images.each do |image|
              receipt_files << image
            end
          end
        else
          # Any other type of attachment
          next
        end

        to_be_transcribed = false
        receipt_files.each do |receipt_file|
          receipt = receipts.create(user_id: user_id, image: receipt_file, note: self.subject, parent: self.expense)
          if self.expense_id.blank? and user.company.ocr_enabled?
            receipt.update(to_be_transcribed: true)
            to_be_transcribed = true
          end
        end
        if to_be_transcribed and Rails.env.production?
          ########## Mailer being triggered ###########
          Constants::TRANSCRIBER_EMAILS.each do |email|
            ReceiptMailer.delay.notify_receipt_upload(user.company, user, receipt, email)
          end
          #############################################
        end
      end
    else
      image_tmp_path = "#{Rails.root}/tmp/images/#{id}.jpg"
      raw_html_text = Paperclip.io_adapters.for(raw_html).read.force_encoding(Encoding::UTF_8)
      document_converter = ReceiptProcessor::BaseConverter.new raw_html_text,
                                                               ReceiptProcessor::BaseConverter::HTML_CONTENT_TYPES.first,
                                                               image_tmp_path
      to_be_transcribed = false
      document_converter.convert do |images|
        images.each do |image|
          receipt = receipts.create(user_id: user_id, image: image, note: self.subject, parent: self.expense)
          if self.expense_id.blank? and user.company.ocr_enabled?
            receipt.update(to_be_transcribed: true)
            to_be_transcribed = true
          end
        end
      end
      if to_be_transcribed and Rails.env.production?
        ########## Mailer being triggered ###########
        Constants::TRANSCRIBER_EMAILS.each do |email|
          ReceiptMailer.delay.notify_receipt_upload(user.company, user, receipt, email)
        end
        #############################################
      end
    end
  end

end
