# == Schema Information
#
# Table name: distance_expenses
#
#  id          :integer          not null, primary key
#  expense_id  :integer
#  is_deleted  :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  distance_id :integer
#

class DistanceExpense < ActiveRecord::Base
  include SoftDeletable

  belongs_to :expense
  belongs_to :distance
  has_many :custom_fields, as: :parent, dependent: :destroy
  has_many :locations, as: :locatable, dependent: :destroy

  accepts_nested_attributes_for :custom_fields
  accepts_nested_attributes_for :locations
  accepts_nested_attributes_for :distance

  validates :distance, presence: true

  delegate :distance_value, to: :distance
end
