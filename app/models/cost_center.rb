# == Schema Information
#
# Table name: cost_centers
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  application :string(255)
#  company_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CostCenter < ActiveRecord::Base
  belongs_to :company
end
