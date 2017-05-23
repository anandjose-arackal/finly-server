# == Schema Information
#
# Table name: manual_expenses
#
#  id         :integer          not null, primary key
#  expense_id :integer
#  merchant   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  is_deleted :boolean          default(FALSE)
#



class ManualExpense < ActiveRecord::Base
  include SoftDeletable

  belongs_to :expense # foreign key expense_id
  has_many :custom_fields, as: :parent, dependent: :destroy
  accepts_nested_attributes_for :custom_fields

  validates :merchant, presence: true

  scope :merchant_like, -> (merchant, expense_ids) do
    where(expense_id: expense_ids).where('lower(merchant) LIKE ?', "%#{merchant.downcase}%").pluck(:merchant)
  end

  def merchant_name
    self.merchant
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
        return cf.value.value
      end
    end
  end

end
