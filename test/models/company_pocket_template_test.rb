# == Schema Information
#
# Table name: company_pocket_templates
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  company_id          :integer
#  user_pocket_type_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  active              :boolean          default(TRUE)
#

require 'test_helper'

class CompanyPocketTemplateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
