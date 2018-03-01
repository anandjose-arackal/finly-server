# == Schema Information
#
# Table name: collect_company_details
#
#  id                        :integer          not null, primary key
#  gst                       :string(255)
#  pan                       :string(255)
#  company_id                :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  company_logo_file_name    :string(255)
#  company_logo_content_type :string(255)
#  company_logo_file_size    :integer
#  company_logo_updated_at   :datetime
#  address                   :text(65535)
#  pin                       :text(65535)
#

require 'test_helper'

class CollectCompanyDetailTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
