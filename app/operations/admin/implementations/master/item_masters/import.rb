class Admin::Implementations::Master::ItemMasters::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'item_masters.import'
  headers ({
      :id => "ID",
      :description => "Description (mandatory)",
      :category => "Category Name",
      :hsn_sac => "HSN - SAC",
      :item_number => "Item Code",
      :item_expense_type => "Expense Type",
      :po_item =>  "PO Item (Y/N)",
      :non_po_item => "Non PO Item (Y/N)",
      :good_service => "Goods or Service ( G / S)",
      :tds_applicable => "TDS Applicable (Y/N)",
      :discount => "Discount",
      :rate => "Rate",
      :destroy => "Destroy"
  })or :item_params
  def create_record(data)
    item_params, messages = set_params(data)
    unless messages.blank?
      return result false, messages.join(', ')
    end

    item = self.company.items.new item_params
    unless item.save
      return result false, item.errors.full_messages
    end
    result true, 'Created Successfully'
  end

  def update_record(data)

    item = self.company.items.non_deleted.find_by id: data[:id]
    unless item
      return result false, "item not found"
    end

    item_params, messages = set_params(data)
    unless messages.blank?
      return result false, messages.join(', ')
    end

    unless item.update(item_params)
      return result false, item.errors.full_messages
    end
    result true, 'Updated Successfully'
  end

  def destroy_records(data)
   item = self.company.items.non_deleted.find_by id: data[:id]
   unless item
    return result false, "item not found"
   end
   unless item.destroy
     return result false, item.errors.full_messages
   end
   result true, "Destroyed Successfully"
  end
  
  def set_params(data)
    messages =[]
    item_expense_types = ItemExpenseType.all
    supply_item_types = SupplyItemType.all
    description = data[:description].to_s
    category_id = company.categories.where(name: data[:category].to_s).first&.id
    if category_id.nil? && data[:category].present?
      messages << "Associated Category Not Found"
    end
    hsn_sac = data[:hsn_sac].blank? ? nil : data[:hsn_sac]
    item_number = (data[:item_number].to_s.blank? ? nil : data[:item_number].to_s)
    discount = data[:discount].to_f&.round(2)
    rate = data[:rate].to_f&.round(2)
    item_expense_type_id = item_expense_types.where(name: data[:item_expense_type].to_s&.downcase)&.first&.id
    product_type_id = nil
    if data[:good_service].to_s.upcase == 'G'
      product_type = 'goods'
    elsif data[:good_service].to_s.upcase == 'S'
      product_type = 'service'
    end
    if product_type.present?
      product_type_id = ProductType.find_by_name(product_type).id
    end
    if item_expense_type_id.nil? && data[:item_expense_type].present?
      messages << "Associated Expense Type Not Found"
    end
    supply_item_type_id = nil
    if data[:po_item].to_s&.upcase  == "Y" && data[:non_po_item].to_s&.upcase  == "Y"
      supply_item_type_id = supply_item_types.find_by_name("po_non_po_item").id
    elsif data[:po_item].to_s&.upcase == "Y"
      supply_item_type_id = supply_item_types.find_by_name("po_item").id
    elsif data[:non_po_item].to_s&.upcase == "Y"
      supply_item_type_id = supply_item_types.find_by_name("non_po_item").id
    end
    if product_type_id.nil?
      messages << "Item Type Goods/Service Need to Specify"
    end

    tds_applicable = nil
    if data[:tds_applicable].to_s&.upcase == "Y"
      tds_applicable = true
    elsif data[:tds_applicable].to_s&.upcase == "N"
      tds_applicable = false
    else
      messages << "TDS Applicable or Not, Need to specify"
    end

    if product_type_id.nil?
      messages << "Item Type Goods/Service Need to specify"
    end

    [{
         description: description,
         category_id: category_id,
         hsn_sac: clean_up_data(hsn_sac),
         item_number: item_number,
         item_expense_type_id: item_expense_type_id,
         supply_item_type_id: supply_item_type_id,
         product_type_id: product_type_id,
         discount: discount,
         rate: rate,
         tds_applicable: tds_applicable
    }, messages]
  end

  def clean_up_data(text)
    if text.is_a?(Float) || text.is_a?(Integer)
      text.to_i.to_s
    else
      text.to_s.strip
    end
  end

end
