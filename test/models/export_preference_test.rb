# == Schema Information
#
# Table name: export_preferences
#
#  id              :integer          not null, primary key
#  company_id      :integer          not null
#  export_field_id :integer          not null
#  name            :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class ExportPreferenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
