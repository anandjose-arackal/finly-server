class Admin::Implementations::Master::Categories::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'categories.import'
  headers [
              :id,
              :parent_id,
              :gl_code,
              :name,
              :destroy
          ]

  def create_record(data)
    category = self.company.categories.new data.except(:id,:destroy)
    unless category.save
      return result false, category.errors.full_messages
    end
    result true, 'Created Successfully'
  end

  def update_record(data)
    category = self.company.categories.find_by id: data[:id]
    unless category
      return result false, "Category not found"
    end

    unless category.update(data.except(:destroy))
      return result false, category.errors.full_messages
    end
    result true,'Updated Successfully'
  end
  
    def destroy_records(data)
     category = self.company.categories.find_by id: data[:id]
     unless category
      return result false, "Category not found"
     end
     begin
       unless category.destroy
         return result false, category.errors.full_messages
       end
     rescue Exception => e
       return result false, "#{e.message}"
     end

     result true, "Destroyed Successfully"
    end

end
