# == Schema Information
#
# Table name: company_kycs
#
#  id                                        :integer          not null, primary key
#  pan_card_file_name                        :string(255)
#  pan_card_content_type                     :string(255)
#  pan_card_file_size                        :integer
#  pan_card_updated_at                       :datetime
#  coi_file_name                             :string(255)
#  coi_content_type                          :string(255)
#  coi_file_size                             :integer
#  coi_updated_at                            :datetime
#  board_resolution_file_name                :string(255)
#  board_resolution_content_type             :string(255)
#  board_resolution_file_size                :integer
#  board_resolution_updated_at               :datetime
#  kyc_status_id                             :integer
#  company_id                                :integer          not null
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  date_of_establishment                     :date
#  street_2                                  :text(65535)
#  street_3                                  :text(65535)
#  registered_mobile_number                  :string(255)
#  pan_card_no                               :string(255)
#  pin_code                                  :string(255)
#  city_code                                 :string(255)
#  aadhar_card_file_name                     :string(255)
#  aadhar_card_content_type                  :string(255)
#  aadhar_card_file_size                     :integer
#  aadhar_card_updated_at                    :datetime
#  vat_registration_certificate_file_name    :string(255)
#  vat_registration_certificate_content_type :string(255)
#  vat_registration_certificate_file_size    :integer
#  vat_registration_certificate_updated_at   :datetime
#  registration_of_trust_file_name           :string(255)
#  registration_of_trust_content_type        :string(255)
#  registration_of_trust_file_size           :integer
#  registration_of_trust_updated_at          :datetime
#  driving_licence_file_name                 :string(255)
#  driving_licence_content_type              :string(255)
#  driving_licence_file_size                 :integer
#  driving_licence_updated_at                :datetime
#  passport_file_name                        :string(255)
#  passport_content_type                     :string(255)
#  passport_file_size                        :integer
#  passport_updated_at                       :datetime
#  company_type_id                           :integer
#  certificate_of_registration_file_name     :string(255)
#  certificate_of_registration_content_type  :string(255)
#  certificate_of_registration_file_size     :integer
#  certificate_of_registration_updated_at    :datetime
#  customer_id                               :string(255)
#

require 'test_helper'

class CompanyKycTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
