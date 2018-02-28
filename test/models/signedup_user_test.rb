# == Schema Information
#
# Table name: signedup_users
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  mobile_number      :string(255)
#  email              :string(255)
#  encrypted_password :string(255)
#  products           :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  company_name       :string(255)
#

require 'test_helper'

class SignedupUserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
