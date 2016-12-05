class Export::Report::Base < Export::Base
  attr_accessor :company, :preference


  class Export::Base::ExportPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :data, :header

    def init
      self.data = params[:data]
      self.header = params[:header]
    end

  end

  class Export::Base::FieldPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :field, :result

    def init
      self.field = params[:preference]
      self.result = params[:result]
    end
  end

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "User or parameters not present."
    end
  end

  def export_params
    params.require(:export).permit(:export_field_id, :name)
  end


  def retrieve_data(preferences, report, expense)
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
    data_arr
  end

end