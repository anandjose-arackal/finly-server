class Admin::Implementations::Master::Categories::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'categories.export'
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
    company.categories
  end

  def id(category)
    category.id
  end

  def parent_id(category)
    category.parent_id
  end

  def gl_code(category)
    category.gl_code
  end

  def name(category)
    category.name
  end
  def destroy(category)
    ''
  end

  def post_process
  end

end
