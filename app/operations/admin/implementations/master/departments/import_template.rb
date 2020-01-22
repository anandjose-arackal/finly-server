class Admin::Implementations::Master::Departments::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'departments.import_template'
  headers({
      :id => "ID",
      :parent_id =>  "Parent Department NAME",
      :name => "Departmet Name",
      :department_code => "Department Code",
      :destroy => "Destroy"
  })

  def valid_request
  end

  def input
    []
  end

  def post_process
  end

end
