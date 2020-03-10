class Expense::Exports::WithReceipts < Expense::Exports::Base
  attr_accessor :expenses, :data, :files

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def pre_validate
    if params[:type].blank?
      add_message :error, 'Export Type not defined'
      return
    end
  end

  def authorize
  end

  def validate
  end

  def process
    self.files = []
    headers = (default_column_names + custom_field_column_names)
    contents = []
    # csv << column_names
    expenses.each do |expense|
      contents << retrieve_data(preferences, expense.report, expense, custom_field_column_names)
      expense.receipts&.each do |receipt|
        self.files << {name: receipt.export_image_file_name, url: receipt.image.url}
      end
    end
    case params[:type]
      when 'xls'
        self.files << {name: 'finly_export.xls', file_contents: Exporter::Spreadsheet.new(user, {headers: headers, contents: contents}).generate_xls}
      when 'csv'
        self.files << {name: 'finly_export.csv', file_contents: Exporter::Spreadsheet.new(user, {headers: headers, contents: contents}).generate_csv}
    end
  end

  def success
    Exporter::AsZip.new(user, {name: 'export', files: self.files}, messages)
  end

end