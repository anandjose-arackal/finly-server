class Admin::Implementations::Master::Categories::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'categories.import'
  headers ({
      :id => "ID",
      :parent_id => "Parent Category Name",
      :gl_code => "GL CODE",
      :name => "Category Name",
      :active => 'Active (Blank or Y for active / N for deactivate)',
      :expense_management =>"Expense Management (Y for Enable",
      :vendor_payments =>"Vendor Payment (Y for Enable",
      :inward_invoice_line_items => "Inward Invoice Line Item (Y for Enable)",
      :destroy => "Destroy"
  })

  attr_accessor :category_params

  def create_record(data)
    category_params, messages = set_params(data)

    unless messages.blank?
      return result false, messages.join(', ')
    end

    category = self.company.categories.new category_params
    unless category.save
      return result false, category.errors.full_messages
    end
    result true, 'Created Successfully'
  end

  def update_record(data)
    category_params, messages = set_params(data)

    unless messages.blank?
      return result false, messages.join(', ')
    end

    category = self.company.categories.find_by id: data[:id]
    unless category
      return result false, "Category not found"
    end

    unless category.update(category_params)
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
    
    def set_params(data)
      messages = []
      parent_name= data[:parent_id]&.to_s

      if parent_name.present?
        parent = company.categories.active.find_by_name(parent_name)&.id
        messages <<  "Parent Category Not found" if parent.blank?
      end

      name = data[:name].to_s
      gl_code = data[:gl_code].to_s
      category_code = data[:category_code].blank? ? nil : data[:category_code]
      expense_management = data[:expense_management].to_s.upcase == 'Y' ? true : false
      vendor_payment = data[:vendor_payments].to_s.upcase == 'Y' ? true : false
      inward_invoice_line_items = data[:inward_invoice_line_items].to_s.upcase == 'Y' ? true : false
      ancestry = parent&.to_s
      active = data[:active].to_s.upcase == 'N' ? false : true

      params = {
              name: name,
              gl_code: gl_code,
              category_code: category_code,
              active: active,
              expense_management: expense_management,
              vendor_payments: vendor_payment,
              inward_invoice_line_items: inward_invoice_line_items,
              ancestry: ancestry
      }
      [params,messages]
    end

end
