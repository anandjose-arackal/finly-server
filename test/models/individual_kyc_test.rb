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
#

require 'test_helper'

class IndividualKycTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
