# == Schema Information
#
# Table name: mcc_category_mappings
#
#  id          :integer          not null, primary key
#  category_id :integer
#  mcc_code    :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class MccCategoryMapping < ApplicationRecord
  belongs_to :category, optional: true
end
