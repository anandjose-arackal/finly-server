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
end
