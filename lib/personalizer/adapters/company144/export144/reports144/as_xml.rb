class Personalizer::Adapters::Company144::Export144::Reports144::AsXml < Personalizer::Adapters::Base
  attr_accessor :default_headers, :reports, :hostel_id, :market_name_id, :column_names, :data, :custom_field_column_names, :default_column_names, :preferences

  def init
  end

  def process
    self.reports = self.op_instance.reports
    self.default_column_names = self.op_instance.default_column_names
    self.custom_field_column_names = self.op_instance.custom_field_column_names
    cf_data = generate_custom_field_data reports
    cf_headers = cf_data[:headers]
    configuration_ids = cf_data[:configuration_ids]
    self.column_names = default_column_names + cf_headers
    self.preferences = user.company.export_preferences
    self.data = []
    reports.each do |r|
      r.expenses.each do |e|
        self.data << retrieve_data(preferences, r, e, cf_data)
      end
    end
    self.op_instance.column_names = column_names
    self.op_instance.data = data
  end


  def generate_custom_field_data(reports)
    # now extract the custom fields from each expense that is a part of all the report
    configuration_ids = []
    headers = []
    values = {}
    # List of field_configuration ids with field name 'Market Name'
    cf_dup_market_ids = []
    # List of field_configuration ids with field name 'Hostel'
    cf_dup_hostel_ids = []
    reports.each do |report|
      report.expenses.each do |expense|
        # this gets all the custom field names from all different types of expenses
        values[expense.id] = {}
        cf = expense.custom_fields
        cf&.each do |custom_field|
          cf_dup_market_ids << custom_field.field_configuration_id if ['Market Name'].include?(custom_field.field_configuration.field_name)
            cf_dup_hostel_ids << custom_field.field_configuration_id if ['Hostel'].include?(custom_field.field_configuration.field_name)
          unless configuration_ids.include?(custom_field.field_configuration_id)
            configuration_ids << custom_field.field_configuration_id unless ['Market Name', 'Hostel'].include?(custom_field.field_configuration.field_name)
          end
          cf_dup_market_ids.flatten.compact.uniq!
          cf_dup_hostel_ids.flatten.compact.uniq!
          # Hostel ID and Market Name ID are the ones that are used in configuration IDs
          if self.hostel_id.blank? || self.market_name_id.blank?
            configuration_ids = setup_configuraton_ids(configuration_ids, cf_dup_market_ids, cf_dup_hostel_ids)
          end
          case
          when cf_dup_market_ids.include?(custom_field.field_configuration_id)
            values[expense.id][self.market_name_id] = custom_field.string_value if values[expense.id][self.market_name_id].blank?
          when cf_dup_hostel_ids.include?(custom_field.field_configuration_id)
            values[expense.id][self.hostel_id] = custom_field.string_value if values[expense.id][self.hostel_id].blank?
          else
            values[expense.id][custom_field.field_configuration_id] = custom_field.string_value
          end
        end
      end
    end
    configuration_ids = configuration_ids.flatten.compact.uniq
    configuration_ids.each do |id|
      field_config = user.company.field_configurations.find_by_id(id)
      headers << field_config.field_name if field_config.present?
    end
    {headers: headers, configuration_ids: configuration_ids, values: values}
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
          data_arr << expense.spent_from.present? ? expense.spent_from&.name : "NONE"
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

  def setup_configuraton_ids(configuration_ids, cf_dup_market_ids, cf_dup_hostel_ids)
    configuration_ids << cf_dup_market_ids[0] if self.market_name_id.blank?
    self.market_name_id = cf_dup_market_ids[0] if self.market_name_id.blank?
    configuration_ids << cf_dup_hostel_ids[0] if self.hostel_id.blank?
    self.hostel_id = cf_dup_hostel_ids[0] if self.hostel_id.blank?
    return configuration_ids
  end


end