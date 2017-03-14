# == Schema Information
#
# Table name: per_diems
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  rate_id    :integer
#  company_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PerDiem < ActiveRecord::Base
  belongs_to :company

  belongs_to :rate, class_name: "Amount"

  validates :rate, presence: true
  validates :company_id, presence: true
  validates :name, presence: true

  accepts_nested_attributes_for :rate

  delegate :rate_value, to: :rate
end
