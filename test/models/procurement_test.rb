# == Schema Information
#
# Table name: procurements
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  procurement_track_id  :integer
#  procurement_status_id :integer
#  vendor_id             :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  user_id               :integer
#  company_id            :integer
#  note                  :text(65535)
#  is_deleted            :boolean          default(FALSE), not null
#  procurement_type      :string(255)
#  transaction_id        :string(255)
#  deleted_at            :datetime
#

require 'test_helper'

class ProcurementTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
