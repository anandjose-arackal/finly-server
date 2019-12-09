# == Schema Information
#
# Table name: distance_expenses
#
#  id                                :integer          not null, primary key
#  expense_id                        :integer
#  is_deleted                        :boolean          default(FALSE)
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  distance_id                       :integer
#  maps_distance_id                  :integer
#  type_id                           :integer
#  odometer_reading_start            :decimal(10, 2)
#  odometer_reading_end              :decimal(10, 2)
#  odometer_reading_receipt_start_id :integer
#  odometer_reading_receipt_end_id   :integer
#  vehicle_rate_id                   :integer
#  distance_rate_id                  :integer
#  distance_unit_id                  :integer
#  deleted_at                        :datetime
#

class DistanceExpense < ApplicationRecord
  include SoftDeletable

  belongs_to :expense, optional: true
  belongs_to :distance, optional: true
  belongs_to :maps_distance, optional: true, class_name: 'Distance'
  has_many :custom_fields, as: :parent, dependent: :destroy
  has_many :locations, as: :locatable, dependent: :destroy
  belongs_to :type, optional: true, class_name: 'DistanceExpenseType'
  belongs_to :odometer_reading_receipt_start, optional: true, class_name: 'Receipt'
  belongs_to :odometer_reading_receipt_end, optional: true, class_name: 'Receipt'
  belongs_to :vehicle_rate, optional: true
  belongs_to :distance_rate, optional: true, class_name: 'Amount'
  belongs_to :distance_unit, optional: true, class_name: 'PhysicalUnit'

  accepts_nested_attributes_for :custom_fields
  accepts_nested_attributes_for :locations
  accepts_nested_attributes_for :distance
  accepts_nested_attributes_for :maps_distance, allow_destroy: true
  accepts_nested_attributes_for :distance_rate

  # validates :distance, presence: true
  validate :distance_presence
  # validates :vehicle_rate, presence: true

  delegate :distance_value, to: :distance, allow_nil: true
  delegate :maps_distance_value, to: :distance, allow_nil: true

  before_save :update_mileage_rates


  def maps_distance_value
    maps_distance&.value
  end

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
    self.distance_value.blank?
  end

  protected
  def distance_presence
    if self.distance_value.blank? and type_id != DistanceExpenseType.id_for(:odometer)
      self.errors.add :distance, 'value cannot be blank'
      return
    end
    if type_id == DistanceExpenseType.id_for(:odometer) and odometer_reading_start.blank?
      self.errors.add :start, 'reading cannot be blank'
      return
    end
    if self.distance_value.present? and self.distance_value <= 0
      self.errors.add :distance, 'value has to be greater than 0'
    end
  end

  def update_mileage_rates
    return unless self.expense.present?
    if vehicle_rate.present?
      if distance_rate.blank?
        build_distance_rate(value: vehicle_rate.rate.value, currency_id: vehicle_rate.rate.currency_id)
      else
        distance_rate.assign_attributes(value: vehicle_rate.rate.value, currency_id: vehicle_rate.rate.currency_id)
      end
      self.distance_unit_id = vehicle_rate.distance_unit_id
    end
  end

end
