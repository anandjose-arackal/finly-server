class MoneyRequestItemCategory < ActiveRecord::Base
  belongs_to :company

  validates :name, presence: true
  validates :company, presence: true

  scope :active, -> (is_active){ where active: is_active }

  def as_json(options={})
    {
        id: id,
        name: name
    }
  end

end
