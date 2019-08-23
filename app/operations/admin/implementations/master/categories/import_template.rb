class Admin::Implementations::Master::Categories::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'categories.import_template'
  headers ({
      :id => "ID",
      :parent_id => "Parent Name/ID",
      :gl_code => "GL CODE",
      :name => "Category Name",
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
