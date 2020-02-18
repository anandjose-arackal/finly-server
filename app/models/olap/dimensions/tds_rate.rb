# == Schema Information
#
# Table name: olap_dimensions_tds_rates
#
#  id                   :bigint           not null, primary key
#  finly_ref_id         :bigint           not null
#  finly_ref_created_at :datetime
#  finly_ref_updated_at :datetime
#  name                 :string(255)
#  tds                  :decimal(10, )
#  company_id           :integer
#  gl_code              :string(255)
#  deleted_at           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  uuid                 :string(36)       not null
#

class Olap::Dimensions::TdsRate < OlapRecord
  include Events::Consumer
include Analytics::Mapper

  transaction_model ::TdsRatesList
  consume 'tds_rate.update', 'tds_rate.create', 'tds_rate.destroy'

  map :name
  map :tds
  map :company_id
  map :gl_code
  map :deleted_at

end
