# == Schema Information
#
# Table name: company_kycs
#
#  id                            :integer          not null, primary key
#  pan_card_file_name            :string(255)
#  pan_card_content_type         :string(255)
#  pan_card_file_size            :integer
#  pan_card_updated_at           :datetime
#  coi_file_name                 :string(255)
#  coi_content_type              :string(255)
#  coi_file_size                 :integer
#  coi_updated_at                :datetime
#  agreement_file_name           :string(255)
#  agreement_content_type        :string(255)
#  agreement_file_size           :integer
#  agreement_updated_at          :datetime
#  board_resolution_file_name    :string(255)
#  board_resolution_content_type :string(255)
#  board_resolution_file_size    :integer
#  board_resolution_updated_at   :datetime
#  kyc_status_id                 :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  company_id                    :integer          not null
#

require 'test_helper'

class CompanyKycTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
