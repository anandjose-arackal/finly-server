class BankTransfer::Users::Exports::Generate < BankTransfer::Users::Exports::Base

attr_accessor :items, :result, :export_name, :sheets

  def process
    @column_names = default_headers
    @data = []
    users.each do |user|
      @data << retrieve_data(user)
    end
    self.sheets = [
        {
            item_headers: @column_names,
            item_contents: @data
        }
    ]
  end

  def post_process
    result = Exporter.new(user, {xlsx: {headers: @column_names, contents: @data, sheets: self.sheets}, expire_file_duration: 3.day}, messages)
    params[:result_file_path] = result.xlsx_exporter.export_file_path
    params[:export_name] = "#{user.company.name}_users_#{Date.today.day}_#{Date.today.month}_#{Date.today.year}"
    params[:data] = @data
    params[:column_names] = @column_names
  end

  def success
    BankTransfer::Users::Exports::Base::ExportPresenter.new(user, params, messages)
  end

end
