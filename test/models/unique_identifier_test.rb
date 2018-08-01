# == Schema Information
#
# Table name: unique_identifiers
#
#  id             :integer          not null, primary key
#  prefix         :string(255)      not null
#  sequence_start :string(255)      not null
#  purpose_id     :integer          not null
#  company_id     :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class UniqueIdentifierTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
