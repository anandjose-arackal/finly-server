class Vendors::Exports::AsXml < Vendors::Exports::Base

  attr_accessor :vendors, :result, :export_name

  def process
    @column_names = default_headers
    @data = []
    vendors.each do |item|
      @data << retrieve_data(item)
    end
  end

  def post_process
    self.export_name = "vendor_#{Date.today.day}_#{Date.today.month}_#{Date.today.year}"
  end

  def success
    Vendors::Exports::Base::ExportPresenter.new(user, {header: @column_names, data: @data, export_name: export_name}, messages)
  end

end
