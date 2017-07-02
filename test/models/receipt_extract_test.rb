# == Schema Information
#
# Table name: receipt_extracts
#
#  id                        :integer          not null, primary key
#  merchant                  :string(255)
#  reference_id              :string(255)
#  amount_id                 :integer
#  receipt_id                :integer          not null
#  receipt_extract_source_id :integer          not null
#  category_id               :integer
#  sourcable_id              :integer
#  sourcable_type            :string(255)
#  illegible                 :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  date                      :date
#  time                      :time
#

require 'test_helper'

class ReceiptExtractTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
