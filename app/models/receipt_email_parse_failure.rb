# == Schema Information
#
# Table name: receipt_email_parse_failures
#
#  id                           :integer          not null, primary key
#  user_id                      :integer
#  subject                      :string(255)
#  sent_at                      :datetime
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
#  original_source_file_name    :string(255)
#  original_source_content_type :string(255)
#  original_source_file_size    :integer
#  original_source_updated_at   :datetime
#  email_id                     :string(255)
#  sender                       :string(255)
#  fixed                        :boolean          default(FALSE)
#  parsed_merchant              :string(255)
#  parsed_amount_value          :string(255)
#  parsed_currency_id           :integer
#  parsed_datetime              :datetime
#  parsed_note                  :text(65535)
#  parsed_category_id           :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  source_file_name             :string(255)
#  source_content_type          :string(255)
#  source_file_size             :integer
#  source_updated_at            :datetime
#

class ReceiptEmailParseFailure < ActiveRecord::Base
  belongs_to :user

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

end
