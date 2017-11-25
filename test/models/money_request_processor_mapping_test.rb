# == Schema Information
#
# Table name: money_request_processor_mappings
#
#  id                         :integer          not null, primary key
#  processor_id               :integer          not null
#  user_id                    :integer          not null
#  processor_accountable_id   :integer
#  processor_accountable_type :string(255)
#  amount_id                  :integer          not null
#  completed_at               :datetime
#  marked_as_completed        :boolean          default(FALSE)
#  status_id                  :integer          not null
#  payment_id                 :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  note                       :text(65535)
#

require 'test_helper'

class MoneyRequestProcessorMappingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
