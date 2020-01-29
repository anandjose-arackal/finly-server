# == Schema Information
#
# Table name: olap_dimensions_companies
#
#  id                   :bigint           not null, primary key
#  finly_ref_id         :bigint           not null
#  finly_ref_created_at :datetime
#  finly_ref_updated_at :datetime
#  name                 :string(255)
#  active               :boolean
#  base_currency_id     :integer
#  status               :integer
#  test_account         :boolean
#  subdomain            :string(255)
#  group_id             :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  uuid                 :string(36)       not null
#

class Olap::Dimensions::Company < OlapRecord
  include Analytics::Mapper

  transaction_model ::Company
  events 'company.update', 'company.create', 'company.destroy'

  map :name
  map :active
  map :base_currency_id
  map :status do |input, record|
    record.status&.name
  end
  map :test_account
  map :subdomain
  map :group_id

end
