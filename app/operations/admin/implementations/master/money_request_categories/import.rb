class Admin::Implementations::Master::MoneyRequestCategories::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'money_request_categories.import'
  attr_accessor :category_params
  headers ({
      :id => "ID",
      :name => "Name",
      :active => "Active ( Y / N )",
      :destroy => "Destroy"
  })

  def create_record(data)
    category_params, messages = validate_params(data)
    unless messages.blank?
      return result false, messages.join(', ')
    end
    money_request_item_category = self.company.money_request_item_categories.new category_params
    unless money_request_item_category.save
      return result false, money_request_item_category.errors.full_messages
    end
    result true, 'Created Successfully'
  end

  def update_record(data)
    category_params, messages = validate_params(data)
    unless messages.blank?
      return result false, messages.join(', ')
    end
    money_request_category = self.company.money_request_item_categories.find_by id: data[:id]
    unless money_request_category
      return result false, "Category not found"
    end

    unless money_request_category.update(category_params)
      return result false, money_request_category.errors.full_messages
    end
    result true, 'Updated Successfully'
  end

  def destroy_records(data)
    category_params, messages = validate_params(data)
    unless messages.blank?
      return result false, messages.join(', ')
    end
    money_request_item_category = self.company.money_request_item_categories.find_by id: data[:id]
    unless money_request_item_category
      return result false, "Category not found"
    end
    unless money_request_item_category.destroy
      return result false, money_request_item_category.errors.full_messages
    end
    result true, "Destroyed Successfully"
  end

  def validate_params(data)
    messages = []
    if data[:name].blank?
      messages << "Category Name cant blank"
    end
    params ={
        name: data[:name],
        active: data[:active].to_s.upcase == 'Y' ? true : false
    }
    [params, messages]
  end

  end