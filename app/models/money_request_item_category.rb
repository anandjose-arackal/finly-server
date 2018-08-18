class MoneyRequestItemCategory < ActiveRecord::Base
  belongs_to :company

  validates :name, presence: true
  validates :company, presence: true

  scope :active, -> (is_active = true) {where active: is_active}
  scope :with_name, -> (name) {where name: name}
  scope :with_id, -> (id) {where id: id}

  def as_json(options = {})
    {
        id: id,
        name: name,
        active: active
    }
  end

end
