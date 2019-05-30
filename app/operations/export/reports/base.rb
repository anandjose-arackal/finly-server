class Export::Reports::Base < Export::Base
  attr_accessor :company, :preference


  class Export::Base::ExportPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :data, :header, :report_names

    def init
      self.data = params[:data]
      self.header = params[:header]
      self.report_names = params[:report_names]
    end

  end

  class Export::Base::FieldPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :field, :result

    def init
      self.field = params[:preference]
      self.result = params[:result]
    end
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "User or parameters not present."
    end
  end

  def export_params
    params.require(:export).permit(:export_field_id, :name)
  end


  def retrieve_data(preferences, report, expense, custom_fields_data)
    data_arr = []
    user = expense.user
    preferences.each do |pref|
      case pref.export_field_id
        when ExportField.type_report_id
          data_arr << report&.id
        when ExportField.type_report_name
          data_arr << report&.name
        when ExportField.type_report_status
          data_arr << report&.status&.name
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
        when ExportField.id_for(:distance_expense_locations)
          if expense.distance_expense?
            data_arr << expense.distance_expense&.locations&.pluck(:name).join(', ')
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
        when ExportField.id_for(:expense_type)
          data_arr << expense.expense_type&.exportable_name
        when ExportField.id_for(:expense_reimbursement)
          data_arr << expense.reimbursable ? 'YES' : 'NO'
        when ExportField.id_for(:spent_from_account)
          data_arr << expense.spent_from.present? ? expense.spent_from.name : "NONE"
        when ExportField.id_for(:policy)
          data_arr << expense&.report&.policy&.name
        when ExportField.id_for(:report_submission_date)
          data_arr << expense&.report&.submitted_at&.strftime("%H:%M, %d/%m/%Y")
        when ExportField.id_for(:report_creation_date)
          data_arr << expense&.report&.created_at&.strftime("%H:%M, %d/%m/%Y")
        else
          data_arr << ''
      end
    end
    # now adding the custom field values for the respective expense
    data_arr += retrieve_custom_field_data(custom_fields_data, expense)
    data_arr
  end

  def retrieve_custom_field_data(custom_fields_data, expense)
    configuration_ids = custom_fields_data[:configuration_ids]
    expense_custom_fields_data = custom_fields_data[:values][expense.id]
    values = []
      configuration_ids.each do |id|
        values << expense_custom_fields_data[id]
      end
    values
  end

  def extract_custom_field_names(reports)
    # now extract the custom fields from each expense that is a part of all the report
    field_names = []
    reports.each do |report|
      report.expenses.each do |expense|
        # this gets all the custom field names from all different types of expenses
        if expense.custom_field_names.present?
          field_names += expense.custom_field_names
        end
      end
    end
    field_names.uniq! || []
  end

  def generate_custom_field_data(reports)
    # now extract the custom fields from each expense that is a part of all the report
    configuration_ids = []
    headers = []
    values = {}
    reports.each do |report|
      report.expenses.each do |expense|
        # this gets all the custom field names from all different types of expenses
        values[expense.id] = {}
        cf = expense.custom_fields
        cf&.each do |custom_field|
          unless configuration_ids.include?(custom_field.field_configuration_id)
            configuration_ids << custom_field.field_configuration_id
            headers << custom_field.field_configuration.field_name
          end
          values[expense.id][custom_field.field_configuration_id] = custom_field.string_value
        end
      end
    end
    # headers: contains the header labels,
    # configuration_ids: contains the field_configuration ids which correlate with the position of headers
    # values: hash[expense_id][field_configuration_id] which contains string values
    {headers: headers, configuration_ids: configuration_ids, values: values}
  end

end
