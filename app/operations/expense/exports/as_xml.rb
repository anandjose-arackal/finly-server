class Expense::Exports::AsXml < Expense::Exports::Base
  attr_accessor :expenses, :data, :file_name, :column_names

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def authorize
  end

  def validate
  end

  def process
    self.column_names = (default_column_names + custom_field_column_names)
    @data = []
    # csv << column_names
    expenses.each do |e|
      @data << retrieve_data(preferences, e.report, e, custom_field_column_names)
    end
  end

  def post_process
    self.file_name = 'export.xls'
  end

  def success
    Expense::Exports::Base::ExportPresenter.new(user, {data: data, file_name: file_name, header: column_names}, messages)
  end
end