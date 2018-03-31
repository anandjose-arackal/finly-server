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
#  is_deleted  :boolean
#

class CostCenter < ActiveRecord::Base

  include SoftDeletable

  belongs_to :company

  scope :with_application, -> (app) {
    where application: app
  }
end
