# == Schema Information
#
# Table name: procurement_terms
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  company_id  :integer
#  is_deleted  :boolean          default(FALSE), not null
#  deleted_at  :datetime
#

require 'test_helper'

class ProcurementTermTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
