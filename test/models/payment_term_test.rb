# == Schema Information
#
# Table name: payment_terms
#
#  id          :integer          not null, primary key
#  name        :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  days_after  :integer
#  description :text(65535)
#  company_id  :integer
#  default     :boolean
#  is_deleted  :boolean          default(FALSE), not null
#  deleted_at  :datetime
#

require 'test_helper'

class PaymentTermTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
