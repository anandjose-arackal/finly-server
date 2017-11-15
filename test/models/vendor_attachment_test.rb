# == Schema Information
#
# Table name: vendor_attachments
#
#  id                         :integer          not null, primary key
#  attached_file_file_name    :string(255)
#  attached_file_content_type :string(255)
#  attached_file_file_size    :integer
#  attached_file_updated_at   :datetime
#  description                :text(65535)
#  vendor_id                  :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

require 'test_helper'

class VendorAttachmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
