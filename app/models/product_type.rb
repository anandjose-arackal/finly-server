# == Schema Information
#
# Table name: product_types
#
#  id         :bigint(8)        not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProductType < ApplicationRecord
  include Seedable

  def self.values
    [:goods, :service]
  end

  def goods?
    self.id == ProductType.id_for(:goods)
  end

  def service?
    self.id == ProductType.id_for(:service)
  end
end
