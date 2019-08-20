class Admin::Implementations::Master::Departments::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'departments.import_template'
  headers [
              :id,
              :parent_id,
              :name,
              :department_code,
              :destroy
          ]

  def valid_request
  end

  def input
    []
  end

  def post_process
  end

end
