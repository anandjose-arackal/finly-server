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

require 'test_helper'

class OutwardInvoiceAttachmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
