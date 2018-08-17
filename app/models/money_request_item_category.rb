class MoneyRequestItemCategory < ActiveRecord::Base
  belongs_to :company

  validates :name, presence: true
  validates :company, presence: true

  def as_json(options={})
    {
        id: id,
        name: name
    }
  end

end
