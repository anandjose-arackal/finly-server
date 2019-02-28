# == Schema Information
#
# Table name: e_way_bills
#
#  id                        :integer          not null, primary key
#  company_id                :integer
#  user_id                   :integer
#  procurement_id            :integer
#  location_id               :integer
#  delivery_location_id      :integer
#  vendor_id                 :integer
#  payment_term_id           :integer
#  procurement_term_id       :integer
#  doc_number                :string(255)
#  date                      :date
#  generated_by              :string(255)
#  valid_from                :datetime
#  valid_to                  :datetime
#  ref_doc_name              :string(255)
#  ref_doc_date              :string(255)
#  amount_id                 :integer
#  hsn_code                  :string(255)
#  reason_for_transportation :string(255)
#  mode                      :string(255)
#  vehicle_number            :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  is_deleted                :boolean          default(FALSE), not null
#  deleted_at                :datetime
#

require 'test_helper'

class EWayBillTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
