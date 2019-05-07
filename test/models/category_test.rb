# == Schema Information
#
# Table name: categories
#
#  id                         :integer          not null, primary key
#  company_id                 :integer          not null
#  name                       :string(255)      not null
#  gl_code                    :string(255)
#  payroll_code               :string(255)
#  active                     :boolean          default(TRUE), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  purpose_id                 :integer
#  expense_management         :boolean
#  vendor_payments            :boolean
#  outward_invoices           :boolean
#  inward_invoice_line_items  :boolean
#  ancestry                   :string(255)
#  outward_invoice_line_items :boolean
#  category_code              :string(255)
#


require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
