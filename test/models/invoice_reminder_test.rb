# == Schema Information
#
# Table name: invoice_reminders
#
#  id                  :integer          not null, primary key
#  days                :integer
#  reference_date_type :string(255)
#  timeframe_type      :string(255)
#  company_id          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  name                :string(255)
#

require 'test_helper'

class InvoiceReminderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
