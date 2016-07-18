# == Schema Information
#
# Table name: export_preferences
#
#  id              :integer          not null, primary key
#  export_field_id :integer          not null
#  name            :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ExportPreference < ActiveRecord::Base
  belongs_to :company
  belongs_to :export_field

  validates :export_field_id, presence: true

  before_save :check_name

  # Check if name is assigned, use default name if not name is assigned to the preference
  def check_name
    if self.name.blank?
      field = ExportField.with_id(self.export_field_id)
      if field.present?
        field = field.first
        self.name = field.name
      end
    end
  end

  def self.build_default_preferences(company)
    if company.export_preferences.present?
      return false
    end
    fields = ExportField.all
    ExportPreference.create company: company, export_field_id: ExportField.type_report_name, name: fields.find_by_id(ExportField.type_report_name).name
    ExportPreference.create company: company, export_field_id: ExportField.type_employee_name, name: fields.find_by_id(ExportField.type_employee_name).name
    ExportPreference.create company: company, export_field_id: ExportField.type_expense_merchant, name: fields.find_by_id(ExportField.type_expense_merchant).name
    ExportPreference.create company: company, export_field_id: ExportField.type_expense_date, name: fields.find_by_id(ExportField.type_expense_date).name
    ExportPreference.create company: company, export_field_id: ExportField.type_expense_category_name, name: fields.find_by_id(ExportField.type_expense_category_name).name
    ExportPreference.create company: company, export_field_id: ExportField.type_expense_currency, name: fields.find_by_id(ExportField.type_expense_currency).name
    ExportPreference.create company: company, export_field_id: ExportField.type_expense_amount, name: fields.find_by_id(ExportField.type_expense_amount).name
    true
  end
end