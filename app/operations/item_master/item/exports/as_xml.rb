class ItemMaster::Item::Exports::AsXml < ItemMaster::Item::Exports::Base

attr_accessor :items, :result, :export_name

  def process
    @column_names = default_headers
    @data = []
    items.each do |item|
      @data << retrieve_data(item)
    end
  end

  def post_process
    self.export_name = "item_#{Date.today.day}_#{Date.today.month}_#{Date.today.year}"
  end

  def success
    ItemMaster::Item::Exports::Base::ExportPresenter.new(user, {header: @column_names, data: @data, export_name: export_name}, messages)
  end

end
