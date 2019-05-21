class Company::Departments::Exports::Base < ::Company::Departments::Base
  attr_accessor  :headers, :departments

  def init
    self.departments = user.company.departments.roots
    self.headers = default_headers
  end

  class Company::Departments::Exports::Base::ExportPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :data, :header, :file_name

    def init
      self.data = params[:data]
      self.header = params[:header]
      self.file_name = params[:export_name]
    end

  end

  private

  def default_headers
    [
        "Department",
        "Sub Department",
        "DepartmentCode"
    ]
  end


  def retrieve_data(departments)
    data_arr = []
    departments.each do |department|
      data_arr << [department.name, '', department.department_code]
      department.children.each do |sub_department|
        data_arr << [department.name, sub_department.name, sub_department.department_code]
      end
    end
    data_arr
  end
end
