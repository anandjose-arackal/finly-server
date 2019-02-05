# == Schema Information
#
# Table name: company_departments
#
#  id                 :integer          not null, primary key
#  name               :string(255)      not null
#  company_id         :integer          not null
#  active             :boolean          default(TRUE)
#  is_deleted         :boolean          default(FALSE)
#  created_by_user_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  deleted_at         :datetime
#

require 'test_helper'

class CompanyDepartmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
