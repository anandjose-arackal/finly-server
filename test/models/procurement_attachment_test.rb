# == Schema Information
#
# Table name: procurement_attachments
#
#  id                        :integer          not null, primary key
#  file_file_name            :string(255)
#  file_content_type         :string(255)
#  file_file_size            :integer
#  file_updated_at           :datetime
#  name                      :string(255)
#  company_id                :integer
#  description               :text(65535)
#  procurement_document_id   :integer
#  procurement_document_type :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  user_id                   :integer
#

require 'test_helper'

class ProcurementAttachmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
