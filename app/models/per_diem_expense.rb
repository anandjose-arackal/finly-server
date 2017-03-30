# == Schema Information
#
# Table name: per_diem_expenses
#
#  id          :integer          not null, primary key
#  per_diem_id :integer
#  expense_id  :integer
#  quantity    :integer
#  is_deleted  :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class PerDiemExpense < ActiveRecord::Base
  include SoftDeletable

  belongs_to :expense
  belongs_to :per_diem
  has_many :custom_fields, as: :parent, dependent: :destroy
  accepts_nested_attributes_for :custom_fields

  validates :per_diem, presence: true

  delegate :per_diem_name, to: :per_diem
end
