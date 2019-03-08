class Expense::Exports::Base < ::Export::Reports::Base
  attr_accessor :preferences, :default_column_names, :custom_field_column_names, :cf_data, :cf_headers

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def init
    expense_presenter = Expense::Index.(user, params)
    self.expenses = expense_presenter.expenses.includes_export
    if self.params[:expense_id].present?
      expense_id = params[:expense_id]
      unless expense_id.is_a?(Array)
        expense_id = expense_id&.split(',')
      end
      self.expenses = self.expenses&.with_id(expense_id)
    end
    self.default_column_names = user.company.export_preferences.pluck(:name)
    self.custom_field_column_names = extract_custom_field_names
    self.preferences = user.company.export_preferences
    self.cf_data = generate_custom_field_data
    self.cf_headers = cf_data[:headers]
  end

  class Expense::Exports::Base::ExportPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :data, :header, :file_name

    def init
      self.data = params[:data]
      self.header = params[:header]
      self.file_name = params[:file_name]
    end
  end

  protected
  def extract_custom_field_names
    # now extract the custom fields from each expense that is a part of all the report
    field_names = []
    self.expenses&.each do |expense|
      # this gets all the custom field names from all different types of expenses
      custom_field_names = expense.custom_field_names
      if custom_field_names.present?
        field_names += custom_field_names
      end
    end
    field_names.uniq! || []
  end

  def generate_custom_field_data
    # now extract the custom fields from each expense that is a part of all the report
    configuration_ids = []
    headers = []
    values = {}
    self.expenses&.each do |expense|
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
    # headers: contains the header labels,
    # configuration_ids: contains the field_configuration ids which correlate with the position of headers
    # values: hash[expense_id][field_configuration_id] which contains string values
    {headers: headers, configuration_ids: configuration_ids, values: values}
  end

end
