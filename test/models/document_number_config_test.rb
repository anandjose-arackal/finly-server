# == Schema Information
#
# Table name: document_number_configs
#
#  id                             :integer          not null, primary key
#  prefix                         :string(255)
#  sequence_start                 :string(255)
#  company_id                     :integer
#  document_number_config_type_id :integer
#  purpose_id                     :integer
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#

require 'test_helper'

class DocumentNumberConfigTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
