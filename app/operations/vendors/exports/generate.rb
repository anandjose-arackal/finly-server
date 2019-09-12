class Vendors::Exports::Generate < Vendors::Exports::Base

  attr_accessor :vendors, :result, :export_name, :items, :sheets

  def validate
  end

  def process
    @column_names = default_headers
    @data = []
    vendors.each do |vendor|
      @data << retrieve_data(vendor)
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
    params[:export_name] = "#{user.company.name}_vendor_#{Date.today.day}_#{Date.today.month}_#{Date.today.year}"
    params[:data] = @data
    params[:column_names] = @column_names
  end

  def success
    Vendors::Exports::Base::ExportPresenter.new(user, params, messages)
  end

end
