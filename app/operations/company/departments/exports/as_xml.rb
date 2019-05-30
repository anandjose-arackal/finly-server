
class Company::Departments::Exports::AsXml < Company::Departments::Exports::Base

attr_accessor :departments, :result, :export_name

  def process
    @column_names = default_headers
    @data = retrieve_data(departments)
  end

  def post_process
    self.export_name = "departments_#{Date.today.day}_#{Date.today.month}_#{Date.today.year}"
  end

  def success
    Company::Departments::Exports::Base::ExportPresenter.new(user, {header: @column_names, data: @data, export_name: export_name}, messages)
  end

end
