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
    filed_parent_expenses_ids =[FieldParentType.id_for(:manual_expense), FieldParentType.id_for(:time_expense),FieldParentType.id_for(:distance_expense), FieldParentType.id_for(:per_diem_expense)]
    FieldConfiguration.where(company_id: user.company_id).non_deleted.joins(:field_parent_mappings).where(field_parent_mappings: { field_parent_type_id: filed_parent_expenses_ids }).pluck(:field_name).uniq
  end


end
