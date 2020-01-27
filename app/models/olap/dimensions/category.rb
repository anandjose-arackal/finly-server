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
#

class Olap::Dimensions::Category < OlapRecord
  include Analytics::Mapper

  transaction_model ::Category
  events 'category.update', 'category.create', 'category.destroy'

  map :name
  map :gl_code
  map :active
  map :company_id
  map :name
  map :gl_code
  map :active
  map :expense_management
  map :vendor_payments
  map :outward_invoices
  map :inward_invoice_line_items
  map :ancestry
  map :outward_invoice_line_items
  map :category_code
  map :gst_applicable
  map :tds_applicable

end
