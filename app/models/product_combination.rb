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

  VALUES = [
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

  def self.name_for(id)
    VALUES[id-1]
  end

end
