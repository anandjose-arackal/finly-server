# == Schema Information
#
# Table name: per_diem_expenses
#
#  id          :integer          not null, primary key
#  per_diem_id :integer
#  expense_id  :integer
#  quantity    :decimal(10, 4)
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

  scope :per_diem_like, -> (query, expense_ids) do
    joins(:per_diem).where(:expense_id => expense_ids).where('per_diems.name LIKE ?', "%#{query}%").pluck(:name)
  end

  validates :per_diem, presence: true
  validate :valid_quantity

  delegate :per_diem_name, to: :per_diem

  scope :with_per_diem_id, -> (per_diem_id) {where per_diem_id: per_diem_id}

  # returns an array of all the associated custom field's names
  def custom_field_names
    field_names = []
    if self.custom_fields.empty?
      field_names = []
    else
      self.custom_fields.each do |field|
        field_names << field.field_configuration.field_name
      end
    end
    field_names
  end

  private

  def valid_quantity
    if self.quantity <= 0
      errors.add(:quantity, "cannot be less than or equal to 0")
    end
  end
end
