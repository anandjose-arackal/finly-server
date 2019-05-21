# action to export a report as xml
# params:
# report_ids: ids of the report to be exported

class Company::Locations::Exports::AsXml < Company::Locations::Exports::Base

  attr_accessor :locations, :result, :export_name

  def process
    @column_names = default_headers
    @data = []
      locations.each do |location|
        @data << retrieve_data(location)
      end
  end

  def post_process
    #adding money_request names in the name of the file
    self.export_name = "locations_#{Date.today.day}_#{Date.today.month}_#{Date.today.year}"
  end

  def success
    Company::Locations::Exports::Base::ExportPresenter.new(user, {header: @column_names, data: @data, export_name: export_name}, messages)
  end

end
