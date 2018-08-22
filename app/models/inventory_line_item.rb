# == Schema Information
#
# Table name: inventory_line_items
#
#  id          :integer          not null, primary key
#  tax         :decimal(20, 10)
#  discount    :decimal(20, 10)
#  hsn_sac     :string(255)
#  company_id  :integer
#  sku         :string(255)
#  rate        :decimal(20, 10)
#  description :text(65535)
#  category_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  note        :text(65535)
#  tax_rate_id :integer
#  is_deleted  :boolean          default(FALSE), not null
#

class InventoryLineItem < ActiveRecord::Base
  belongs_to :company
  belongs_to :category

  validates :rate, presence: true
  validates :description, presence: true

  scope :search, -> (term) {
    where('description like ? OR sku like ? OR note like ? OR hsn_sac like ?', "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%")
  }

  scope :filter_category_id, -> (category_id) {
    where category_id: category_id
  }

  def as_json
    
  end
end
