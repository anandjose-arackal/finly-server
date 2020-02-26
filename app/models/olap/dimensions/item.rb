# == Schema Information
#
# Table name: olap_dimensions_items
#
#  id                   :bigint           not null, primary key
#  finly_ref_id         :bigint           not null
#  finly_ref_created_at :datetime
#  finly_ref_updated_at :datetime
#  tax                  :decimal(10, )
#  discount             :decimal(10, )
#  hsn_sac              :string(255)
#  company_id           :integer
#  sku                  :string(255)
#  rate                 :decimal(10, )
#  description          :text(65535)
#  category_id          :integer
#  note                 :text(65535)
#  tax_rate_id          :integer
#  is_deleted           :boolean
#  item_code            :string(255)
#  account              :string(255)
#  supply_item_type_id  :integer
#  deleted_at           :datetime
#  product_type_id      :integer
#  item_number          :string(255)
#  unit_of_measurement  :string(255)
#  user_id              :integer
#  active               :boolean
#  item_expense_type_id :integer
#  tds_applicable       :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  uuid                 :string(36)       not null
#

class Olap::Dimensions::Item < OlapRecord
  include Events::Consumer
  include Analytics::Mapper

  transaction_model ::Item
  consume 'item.update', 'item.create', 'item.destroy'

  map :tax
  map :discount
  map :hsn_sac
  map :company_id
  map :sku
  map :rate
  map :description
  map :category_id
  map :note
  map :tax_rate_id
  map :is_deleted
  map :item_code
  map :account
  map :supply_item_type_id
  map :deleted_at
  map :product_type_id
  map :item_number
  map :unit_of_measurement
  map :user_id
  map :active
  map :item_expense_type_id
  map :tds_applicable

end
