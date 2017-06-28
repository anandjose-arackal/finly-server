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
#  board_resolution_file_name    :string(255)
#  board_resolution_content_type :string(255)
#  board_resolution_file_size    :integer
#  board_resolution_updated_at   :datetime
#  kyc_status_id                 :integer
#  company_id                    :integer          not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  customer_type_name            :string(255)
#  date_of_establishment         :date
#  street_2                      :text(65535)
#  street_3                      :text(65535)
#  registered_mobile_number      :string(255)
#  pan_card_no                   :string(255)
#  pin_code                      :string(255)
#  city_code                     :string(255)
#

require 'test_helper'

class CompanyKycTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
