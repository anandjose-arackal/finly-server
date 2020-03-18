# == Schema Information
#
# Table name: olap_dimensions_tax_rates
#
#  id                   :bigint           not null, primary key
#  finly_ref_id         :bigint           not null
#  finly_ref_created_at :datetime
#  finly_ref_updated_at :datetime
#  name                 :string(255)
#  rate                 :decimal(10, )
#  internal_id          :string(255)
#  company_id           :integer
#  is_deleted           :boolean
#  deleted_at           :datetime
#  cgst                 :decimal(10, )
#  sgst                 :decimal(10, )
#  igst                 :decimal(10, )
#  igst_internal_id     :string(255)
#  cgst_internal_id     :string(255)
#  sgst_internal_id     :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  uuid                 :string(36)       not null
#

class Olap::Dimensions::TaxRate < OlapRecord
  include Events::Consumer
  include Analytics::Mapper

  transaction_model ::TaxRate
  consume 'tax_rate.update', 'tax_rate.create', 'tax_rate.destroy'

  map :name
  map :rate
  map :internal_id
  map :company_id
  map :is_deleted
  map :deleted_at
  map :cgst
  map :sgst
  map :igst
  map :igst_internal_id
  map :cgst_internal_id
  map :sgst_internal_id

end
