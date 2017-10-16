# == Schema Information
#
# Table name: quickbooks_references
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  company_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  reference_type_id :integer
#

require 'test_helper'

class QuickbooksReferenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
