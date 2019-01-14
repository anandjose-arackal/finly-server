# == Schema Information
#
# Table name: periods
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class Period < ApplicationRecord

  # VALUES = {day: 1, week: 2, fortnight: 3, month: 4, quarter: 5, year: 6}
  VALUES = {day: 1, week: 2, month: 3, quarter: 4, year: 5, hour: 6, fortnightly: 7}

  validates :name, presence: true

  scope :with_name, -> (name) {where name: name}

  def period
    self.name
  end

  def period_name
    self.name
  end

  def self.id_for(item)
    VALUES[item]
  end

  def self.name_for(item)
    VALUES.key(item)
  end

  def self.seed_data
    count = Period.count
    VALUES.each do |key, value|
      if count == 0 or Period.with_name(key).blank?
        Period.create id: value, name: key
      end
    end
  end

  def day?
    self.id == Period.id_for(:day)
  end

  def week?
    self.id == Period.id_for(:week)
  end

  def month?
    self.id == Period.id_for(:month)
  end

  def quarter?
    self.id == Period.id_for(:quarter)
  end

  def year?
    self.id == Period.id_for(:year)
  end

  def hour?
    self.id == Period.id_for(:hour)
  end

  def as_json(options= {})
    {
        id: self.id,
        name: self.name
    }
  end

end
