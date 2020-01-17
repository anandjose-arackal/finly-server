class Export::Expense::Base < Export::Base

  class Export::Expense::Base::ExportPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :data, :file_name

    def init
      self.data = params[:data]
      self.file_name = params[:file_name]
    end
  end

  def retrieve_data(preferences, report, expense, custom_field_names)
    data_arr = []
    user = report&.user || expense.user
    preferences.each do |pref|
      case pref.export_field_id
        when ExportField.type_report_id
          data_arr << report.id
        when ExportField.type_report_name
          data_arr << report.name
        when ExportField.type_report_status
          data_arr << report.status.name
        when ExportField.type_employee_name
          data_arr << user.name
        when ExportField.type_employee_id
          data_arr << user.employee_id
        when ExportField.type_payroll_id
          data_arr << user.payroll_id
        when ExportField.type_expense_id
          data_arr << expense.id
        when ExportField.type_expense_merchant
          data_arr << expense.merchant_name
        when ExportField.type_expense_category_name
          data_arr << expense.category_name
        when ExportField.type_expense_currency
          data_arr << expense.amount&.currency&.country_code
        when ExportField.type_expense_amount
          data_arr << expense.amount&.value
        when ExportField.type_expense_date
          data_arr << expense.date
        when ExportField.type_expense_note
          data_arr << expense.note
        when ExportField.type_expense_status
          data_arr << expense.expense_status&.name&.humanize
        when ExportField.id_for(:employee_email)
          data_arr << expense.user.email
        when ExportField.id_for(:employee_mobile_number)
          data_arr << expense.user.mobile_number
        when ExportField.id_for(:distance_expense_source)
          if expense.distance_expense?
            data_arr << expense.distance_expense.locations&.first&.name
          else
            data_arr << ''
          end
        when ExportField.id_for(:distance_expense_destination)
          if expense.distance_expense?
            data_arr << expense.distance_expense.locations&.last&.name
          else
            data_arr << ''
          end
        when ExportField.id_for(:distance_in_km)
          if expense.distance_expense?
            data_arr << expense.distance_expense.distance_value
          else
            data_arr << ''
          end
        when ExportField.id_for(:maps_distance_in_km)
          if expense.distance_expense?
            data_arr << expense.distance_expense.maps_distance_value
          else
            data_arr << ''
          end
        else
          data_arr << ''
      end
    end
    # now adding the custom field values for the respective expense
    data_arr += retrieve_custom_field_data(custom_field_names, expense)
    data_arr
  end

  def retrieve_custom_field_data(custom_field_names, expense)
    values = []
    field_names = expense.custom_field_names
    custom_field_names.each do |column|
      if field_names.include?(column)
        values << expense.custom_field_value_by_name(column)
      else
        values << ''
      end
    end
    values
  end

  # def extract_custom_field_names(expenses)
  #   # now extract the custom fields from each expense that is a part of all the report
  #   field_names = []
  #   expenses.each do |expense|
  #     # this gets all the custom field names from all different types of expenses
  #     if expense.custom_field_names.present?
  #       field_names += expense.custom_field_names
  #     end
  #   end
  #   field_names.uniq!
  # end

  def extract_custom_field_names(expenses=nil)
    filed_parent_expenses_ids =[FieldParentType.id_for(:manual_expense), FieldParentType.id_for(:time_expense),FieldParentType.id_for(:distance_expense), FieldParentType.id_for(:per_diem_expense) ]
    FieldConfiguration.where(company_id: user.company_id).non_deleted.joins(:field_parent_mappings).where(field_parent_mappings: { field_parent_type_id: filed_parent_expenses_ids }).pluck(:field_name).uniq
  end

end