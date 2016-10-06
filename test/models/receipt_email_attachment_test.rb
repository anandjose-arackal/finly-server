# == Schema Information
#
# Table name: receipt_email_attachments
#
#  id                               :integer          not null, primary key
#  receipt_email_id                 :integer
#  original_attachment_file_name    :string(255)
#  original_attachment_content_type :string(255)
#  original_attachment_file_size    :integer
#  original_attachment_updated_at   :datetime
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#


require 'test_helper'

class ReceiptEmailAttachmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
