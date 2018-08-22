# == Schema Information
#
# Table name: accounting_system_configurations
#
#  id                :integer          not null, primary key
#  company_id        :integer          not null
#  enabled           :boolean          default(FALSE)
#  accounting_system :string(255)
#  options           :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'test_helper'

class AccountingSystemConfigurationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
