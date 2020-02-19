# == Schema Information
#
# Table name: olap_dimensions_categories
#
#  id                         :bigint           not null, primary key
#  finly_ref_id               :bigint           not null
#  finly_ref_created_at       :datetime
#  finly_ref_updated_at       :datetime
#  company_id                 :integer
#  name                       :string(255)
#  gl_code                    :string(255)
#  active                     :boolean
#  expense_management         :boolean
#  vendor_payments            :boolean
#  outward_invoices           :boolean
#  inward_invoice_line_items  :boolean
#  ancestry                   :string(255)
#  outward_invoice_line_items :boolean
#  category_code              :string(255)
#  gst_applicable             :boolean
#  tds_applicable             :boolean
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  uuid                       :string(36)       not null
#

require 'rails_helper'

RSpec.describe Olap::Dimensions::Category, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
