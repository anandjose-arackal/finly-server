# == Schema Information
#
# Table name: branch_locations
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  gstin                 :string(255)
#  pan                   :string(255)
#  company_id            :integer
#  address_1             :string(255)
#  address_2             :string(255)
#  city                  :string(255)
#  state_id              :integer
#  country               :string(255)
#  pin                   :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  contact_name          :string(255)
#  contact_mobile_number :string(255)
#  is_deleted            :boolean          default(FALSE), not null
#  deleted_at            :datetime
#  location_code         :string(255)
#

require 'test_helper'

class BranchLocationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
