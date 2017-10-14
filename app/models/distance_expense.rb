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
#  odometer_reading_one              :decimal(10, )
#  odometer_reading_two              :decimal(10, )
#  odometer_reading_receipt_one_id   :integer
#  odometer_reading_receipt_two_id   :integer
#  odometer_reading_start            :decimal(10, )
#  odometer_reading_end              :decimal(10, )
#  odometer_reading_receipt_start_id :integer
#  odometer_reading_receipt_end_id   :integer
#

class DistanceExpense < ActiveRecord::Base
  include SoftDeletable

  belongs_to :expense
  belongs_to :distance
  belongs_to :maps_distance, class_name: 'Distance'
  has_many :custom_fields, as: :parent, dependent: :destroy
  has_many :locations, as: :locatable, dependent: :destroy

  accepts_nested_attributes_for :custom_fields
  accepts_nested_attributes_for :locations
  accepts_nested_attributes_for :distance
  accepts_nested_attributes_for :maps_distance, allow_destroy: true

  # validates :distance, presence: true
  validate :distance_presence

  delegate :distance_value, to: :distance, allow_nil: true
  delegate :maps_distance_value, to: :distance, allow_nil: true

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

  protected
  def distance_presence
    if self.distance_value.blank? and type_id != DistanceExpenseType.id_for(:odometer)
      self.errors.add :distance, 'value cannot be blank'
    end
    if self.distance_value.present? and self.distance_value <= 0
      self.errors.add :distance, 'value has to be greater than 0'
    end
  end

end
