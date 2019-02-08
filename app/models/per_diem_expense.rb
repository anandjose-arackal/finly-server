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
#  deleted_at  :datetime
#

class PerDiemExpense < ApplicationRecord
  include SoftDeletable

  belongs_to :expense, optional: true
  belongs_to :per_diem, optional: true

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

  # returns an array of the respective custom field values
  def custom_field_values
    field_values = []
    if self.custom_fields.empty?
      field_values = []
    else
      self.custom_fields.each do |field|
        field_values << field.value.value
      end
    end
    field_values
  end

  def custom_field_value_by_name(name)
    self.custom_fields.each do |cf|
      if cf.field_configuration.field_name.casecmp(name) == 0
        return cf&.value&.value
      end
    end
  end

  def incomplete?
    false
  end

  private

  def valid_quantity
    if self.quantity <= 0
      errors.add(:quantity, "cannot be less than or equal to 0")
    end
  end
end
