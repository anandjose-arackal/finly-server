# == Schema Information
#
# Table name: individual_kycs
#
#  id                    :integer          not null, primary key
#  id_proof_file_name    :string(255)
#  id_proof_content_type :string(255)
#  id_proof_file_size    :integer
#  id_proof_updated_at   :datetime
#  pan_card_file_name    :string(255)
#  pan_card_content_type :string(255)
#  pan_card_file_size    :integer
#  pan_card_updated_at   :datetime
#  kyc_status_id         :integer
#  user_id               :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require 'test_helper'

class IndividualKycTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
