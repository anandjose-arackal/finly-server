# == Schema Information
#
# Table name: time_expenses
#
#  id             :integer          not null, primary key
#  expense_id     :integer
#  is_deleted     :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  time_object_id :integer
#

class TimeExpense < ActiveRecord::Base

  include SoftDeletable

  belongs_to :expense
  has_many :custom_fields, as: :parent, dependent: :destroy
  accepts_nested_attributes_for :custom_fields

  belongs_to :time_object

  validates :time_object, presence: true

  accepts_nested_attributes_for :time_object

  delegate :time_object_value, to: :time_object

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
        return cf.value.value
      end
    end
  end
end
