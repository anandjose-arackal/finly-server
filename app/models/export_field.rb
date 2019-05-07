# == Schema Information
#
# Table name: export_fields
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ExportField < ApplicationRecord

  scope :with_id, ->(id) { where id: id }

  VALUES = {
      1 => "Employee Name",
      2 => "Employee Id",
      3 => "Payroll Id",
      4 => "Report Id",
      5 => "Report name",
      6 => "Report Status",
      7 => "Expense Id",
      8 => "Expense Merchant",
      9 => "Expense Currency",
      10 => "Expense Amount",
      11 => "Expense Date",
      12 => "Expense Category Name",
      13 => "Custom Field",
      14 => "Expense Note",
      15 => "Expense Status",
      16 => "Employee Email",
      17 => "Employee Mobile Number",
      20 => "Distance In Km",
      21 => "Maps Distance in Km",
      22 => "Distance Expense Locations",
      23 => "Expense Type",
      24 => "Expense Reimbursement",
      25 => "Spent from Account",
      26 => "Policy",
      27 => "Report Submission Date",
      29 => "Report Creation Date"
  }

  def self.id_for(name_in_sym)
    VALUES.each do |key, value|
      if value.underscore.gsub(' ', '_').to_sym == name_in_sym
        return key
      end
    end
  end

  def self.seed_data
    VALUES.each do |key, value|
      if ExportField.find_by(name: value).present?
        next
      else
        ExportField.create(id: key, name: value)
      end
    end
  end

  def self.type_employee_name
    1
  end

  def self.type_employee_id
    2
  end

  def self.type_payroll_id
    3
  end

  def self.type_report_id
    4
  end

  def self.type_report_name
    5
  end

  def self.type_report_status
    6
  end

  def self.type_expense_id
    7
  end

  def self.type_expense_merchant
    8
  end

  def self.type_expense_currency
    9
  end

  def self.type_expense_amount
    10
  end

  def self.type_expense_date
    11
  end

  def self.type_expense_category_name
    12
  end

  def self.type_custom_field_name
    13
  end

  def self.type_expense_note
    14
  end

  def self.type_expense_status
    15
  end

end
