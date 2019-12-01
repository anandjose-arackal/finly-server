# == Schema Information
#
# Table name: olap_dimensions_policies
#
#  id                     :bigint           not null, primary key
#  finly_ref_id           :bigint           not null
#  finly_ref_created_at   :datetime
#  finly_ref_updated_at   :datetime
#  name                   :string(255)
#  company_id             :integer
#  owner_id               :integer
#  default                :boolean
#  is_deleted             :boolean
#  description            :text(65535)
#  base_currency_id       :integer
#  application            :string(255)
#  settlement_currency_id :integer
#  deleted_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Olap::Dimensions::Policy < OlapRecord
  include Analytics::Mapper

  transaction_model ::Policy
  events 'policy.update', 'policy.create', 'policy.destroy'

  map :name
  map :company_id
  map :owner_id
  map :default
  map :is_deleted
  map :description
  map :base_currency_id
  map :application
  map :settlement_currency_id
  map :deleted_at

end
