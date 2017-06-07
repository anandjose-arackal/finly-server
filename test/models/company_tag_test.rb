# == Schema Information
#
# Table name: company_tags
#
#  id                              :integer          not null, primary key
#  company_id                      :integer          not null
#  name                            :string(255)      not null
#  gl_code                         :string(255)
#  active                          :boolean          default(TRUE), not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  external_tag_type               :string(255)
#  external_integration_type       :string(255)
#  external_id                     :string(255)
#  external_additional_information :string(255)
#  external_updated_at             :string(255)
#


require 'test_helper'

class CompanyTagTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
