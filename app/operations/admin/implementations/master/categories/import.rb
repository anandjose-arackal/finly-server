class Admin::Implementations::Master::Categories::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'categories.import'
  halt_on_failure!
  headers [
              :id,
              :parent_id,
              :gl_code,
              :name,
              :delete
          ]

  def create_record(data)
    category = self.company.categories.new data.except(:id)
    unless category.save
      return result false, category.errors.full_messages
    end
    result true
  end

  def update_record(data)
    category = self.company.categories.find_by id: data[:id]
    unless category
      return result false, "Category not found"
    end

    unless category.update(data)
      return result false, category.errors.full_messages
    end
    result true
  end

end
