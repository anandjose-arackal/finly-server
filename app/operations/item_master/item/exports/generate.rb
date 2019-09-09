class ItemMaster::Item::Exports::Generate < ItemMaster::Item::Exports::Base

attr_accessor :items, :result, :export_name, :sheets

  def process
    @column_names = default_headers
    @data = []
    items.each do |item|
      @data << retrieve_data(item)
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
    params[:export_name] = "item_#{Date.today.day}_#{Date.today.month}_#{Date.today.year}"
    params[:data] = @data
    params[:column_names] = @column_names
  end

  def success
    # ItemMaster::Item::Exports::Base::ExportPresenter.new(user, {header: @column_names, data: @data, export_name: export_name}, messages)
    ItemMaster::Item::Exports::Base::ExportPresenter.new(user, params, messages)
  end

end
