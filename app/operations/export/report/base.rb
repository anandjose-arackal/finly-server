class Export::Report::Base < Export::Base
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


  def retrieve_data(preferences, report, expense, custom_field_names)
    data_arr = []
    user = report.user
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
          data_arr << expense.amount.currency.country_code
        when ExportField.type_expense_amount
          data_arr << expense.amount.value
        when ExportField.type_expense_date
          data_arr << expense.date
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
    field_names
  end

end
