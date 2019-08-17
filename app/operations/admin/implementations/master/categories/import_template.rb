class Admin::Implementations::Master::Categories::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'categories.import_template'
  headers [
              :id,
              :parent_id,
              :gl_code,
              :name,
              :destroy
          ]

  def valid_request

  end

  def input
    binding.pry
    []
  end

  def post_process
  end

end
