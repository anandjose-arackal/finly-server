# == Schema Information
#
# Table name: payment_file_configurations
#
#  id         :integer          not null, primary key
#  format     :string(255)
#  company_id :integer          not null
#  payload    :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class PaymentFileConfigurationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
