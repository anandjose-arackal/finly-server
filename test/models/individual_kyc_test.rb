# == Schema Information
#
# Table name: individual_kycs
#
#  id                         :integer          not null, primary key
#  id_proof_file_name         :string(255)
#  id_proof_content_type      :string(255)
#  id_proof_file_size         :integer
#  id_proof_updated_at        :datetime
#  kyc_status_id              :integer
#  user_id                    :integer          not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  address_proof_file_name    :string(255)
#  address_proof_content_type :string(255)
#  address_proof_file_size    :integer
#  address_proof_updated_at   :datetime
#  review_position            :integer
#  admin_review_workflow_id   :integer          not null
#  upgraded_by_resource_id    :integer
#  type_id                    :integer
#  kyc_file_1_file_name       :string(255)
#  kyc_file_1_content_type    :string(255)
#  kyc_file_1_file_size       :integer
#  kyc_file_1_updated_at      :datetime
#  kyc_file_2_file_name       :string(255)
#  kyc_file_2_content_type    :string(255)
#  kyc_file_2_file_size       :integer
#  kyc_file_2_updated_at      :datetime
#  kyc_number                 :string(255)
#  company_id                 :integer          not null
#

require 'test_helper'

class IndividualKycTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
