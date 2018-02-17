# == Schema Information
#
# Table name: inventory_line_items
#
#  id          :integer          not null, primary key
#  tax         :decimal(10, 5)
#  discount    :decimal(10, 5)
#  hsn_sac     :string(255)
#  company_id  :integer
#  sku         :string(255)
#  rate        :decimal(10, 5)
#  description :text(65535)
#  category_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class InventoryLineItem < ActiveRecord::Base
  belongs_to :company
  belongs_to :category

  validates :rate, presence: true
  validates :description, presence: true
end
