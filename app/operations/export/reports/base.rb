class Export::Reports::Base < Export::Base
  attr_accessor :company, :preference, :loose_headers,  :custom_field_data


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


  def retrieve_data(preferences, report, expense, custom_field_column_names)
    data_arr = []
    user = expense.user

    gst_applicable = expense.category&.gst_applicable?

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
          data_arr << expense.category&.full_name
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
      when ExportField.id_for(:receipt_link)
        data_arr << expense&.receipts&.first&.image&.url
      when ExportField.id_for(:igst)
        data_arr << (gst_applicable ? (expense.gst_type&.name == 'igst' ? (expense.gst_amount&.value).round(2) : '') : '')
      when ExportField.id_for(:cgst)
        data_arr << ((gst_applicable ? (expense.gst_type&.name == 'cgst_sgst' ? ((expense.gst_amount&.value) / 2).round(2) : '') : '') rescue '')
      when ExportField.id_for(:sgst)
        data_arr << ((gst_applicable ? (expense.gst_type&.name == 'cgst_sgst' ? ((expense.gst_amount&.value) / 2).round(2) : '') : '') rescue '')
      when ExportField.id_for(:department)
        data_arr << expense.user.department&.name
      when ExportField.id_for(:location)
        data_arr << expense.user.location&.name
      when ExportField.id_for(:cost_center)
        data_arr << expense.user.cost_center&.name
      else
          data_arr << ''
      end
    end
    # now adding the custom field values for the respective expense
    data_arr += retrieve_custom_field_values(expense, report, custom_field_column_names)
  end


  def extract_custom_field_names(reports = nil)
    filed_parent_expenses_ids =[FieldParentType.id_for(:manual_expense), FieldParentType.id_for(:time_expense),FieldParentType.id_for(:distance_expense), FieldParentType.id_for(:per_diem_expense), FieldParentType.id_for(:report) ]
    FieldConfiguration.where(company_id: user.company_id).non_deleted.joins(:field_parent_mappings).where(field_parent_mappings: { field_parent_type_id: filed_parent_expenses_ids }).pluck(:field_name).uniq
  end

  def retrieve_custom_field_values(expense, report, custom_field_column_names)
    records = []
    cf = expense&.custom_fields.to_a + report&.custom_fields.to_a
    custom_field_column_names.each do |cf_name|
      value = ''
      # expense.custom_fields.map {|ecf| value = (ecf.configured_field_value || '') if ecf.field_configuration.field_name == cf_name}.reject(&:blank?)
      # records << value
      cf.map {|ecf| value = (ecf.configured_field_value || '') if ecf.field_configuration.field_name == cf_name}
      records << value
    end
    records
  end


end
