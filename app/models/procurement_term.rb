# == Schema Information
#
# Table name: procurement_terms
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ProcurementTerm < ActiveRecord::Base

  belongs_to :company

  validates :name, presence: true
  validates :description, presence: true
end
