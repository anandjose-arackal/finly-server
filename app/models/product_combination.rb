# == Schema Information
#
# Table name: product_combinations
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class ProductCombination < ActiveRecord::Base

  VALUES = {transportation: 1,
            ground_transportation: 2,
            travel: 3,
            fuel: 6}

  TYPES = [
      'Transportation',
      'Ground Transportation',
      'Travel',
      'Hotel/Restaurant/Lodging',
      'Food/Meals',
      'Fuel',
      'Pharmacies',
      'Mobile Recharge',
      'Utility Bills',
      'Disallow Liquor/Bar/Clubs',
      'Metro',
      'Retail',
      'Electronics',
      'Hardware and Construction',
      'Groceries',
      'Logistics',
      'Entertainment',
      'Healthcare'
  ]

  # todo - to be remapped once the new combinations are received from ItzCash
  CODES = {1 => 'GPRESC',
           2 => 'GPROL1',
           3 => 'GPROL2'}

  def self.id_for(name)
    VALUES[name]
  end

  def self.name_for(id)
    TYPES[id-1]
  end

  def product_code_name
    self.name
  end

end
