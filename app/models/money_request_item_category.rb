# == Schema Information
#
# Table name: money_request_item_categories
#
#  id         :integer          not null, primary key
#  company_id :integer          not null
#  name       :string(255)      not null
#  active     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MoneyRequestItemCategory < ApplicationRecord
  belongs_to :company, optional: true

  validates :name, presence: true
  validates :company, presence: true

  scope :active, -> (is_active = true) {where active: is_active}
  scope :with_name, -> (name) {where name: name}
  scope :with_id, -> (id) {where id: id}

  def category_name
    name
  end

  def as_json(options = {})
    {
        id: id,
        name: name,
        active: active
    }
  end

end
