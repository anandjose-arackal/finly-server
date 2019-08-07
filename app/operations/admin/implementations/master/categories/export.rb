class Admin::Implementations::Master::Categories::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'categories.list'
  headers [
              :id,
              :parent_id,
              :gl_name,
              :name
          ]

  def valid_request

  end

  def input
    Category.limit(10)
  end

  def id(category)
    category.id
  end

  def parent_id(category)
    category.parent_id
  end

  def gl_name(category)
    category.gl_name
  end

  def name(category)
    category.name
  end


end
