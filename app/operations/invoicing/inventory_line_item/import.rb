class Invoicing::InventoryLineItem::Import < Invoicing::InventoryLineItem::Base

  attr_accessor :company, :inventory_data, :file, :headers, :data, :contents,
                :has_errors, :inventory_line_items, :validation_data, :attr_mapping

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
      return
    end
    if params[:file].blank?
      add_message :error, "No file uploaded"
    end
  end

  def init
    self.company = user.company
    self.file = params[:file]

    self.attr_mapping = [
        :description, # 0
        :supply_item_type_id, # 1
        :sku, # 2
        :item_code, # 3
        :category_id, # 4
        :hsn_sac, # 5
        :rate, # 6
        :discount, # 7
        :tax_rate_id, # 8
        :note # 9
    ]

    self.inventory_data = ImportUtil.load_spreadsheet(file, self.attr_mapping, {skip_empty_lines: true})



    # Headers for the dump after import
    self.headers = retrieve_headers

    # Contents for the dump after import (includes status and errors if any)
    self.contents = []

    self.has_errors = false

    # Stores all the inventory line items from validate and are saved in process
    self.inventory_line_items = []

    # Data required for validating each line item
    self.validation_data = {
        supply_item_type_ids: SupplyItemType.pluck(:id),
        category_ids: user.company.categories.inward_invoice_line_items_only.pluck(:id),
        tax_rate_ids: user.company.tax_rates.pluck(:id)
    }
  end

  def validate
    if self.inventory_data.blank?
      add_message :error, "Empty spreadsheet uploaded"
    end

    self.inventory_data.each_with_index do |inventory_item_params, index|
      # Get all the values from params into an array for dump
      content = inventory_item_params.values

      # Goes at the last column, contains all error messages
      error_message = []


      supply_item_type_id = inventory_item_params[:supply_item_type_id]&.to_i
      if supply_item_type_id.blank? || self.validation_data[:supply_item_type_ids].exclude?(supply_item_type_id)
        content[1] = add_error(content[1])
        error_message.push("Invalid Item Type ID")
      end

      category_id = inventory_item_params[:category_id]&.to_i
      if category_id.blank? || self.validation_data[:category_ids].exclude?(category_id)
        content[4] = add_error(content[4])
        error_message.push("Invalid Category ID")
      end

      tax_rate_id = inventory_item_params[:tax_rate_id]&.to_i
      if tax_rate_id.blank? || self.validation_data[:tax_rate_ids].exclude?(tax_rate_id)
        content[8] = add_error(content[8])
        error_message.push("Invalid Tax Rate ID")
      end

      # Initialize inventory_line_item
      inventory_line_item = user.company.inventory_line_items.build(inventory_item_params)

      # Push the global array, so it can be saved in process
      self.inventory_line_items.push(inventory_line_item)

      unless inventory_line_item.valid?
        invalid_attrs = inventory_line_item.errors.keys
        invalid_attr_messages = inventory_line_item.errors.full_messages

        invalid_attrs.each_with_index do |invalid_attr, index|
          attr_index = self.attr_mapping.index(invalid_attr)
          if attr_index.present?
            content[attr_index] = add_error(content[attr_index])
            error_message.push(invalid_attr_messages[index])
          end
        end
      end

      if error_message.present?
        content.push "ERROR"
        content.push error_message.join(", ")
      else
        content.push "Success"
      end

      self.contents << content
    end
  end

  def process

    unless has_errors
      self.inventory_line_items.each do |invoice_line_item|
        invoice_line_item.save
      end
    end
  end

  def success
    params[:import_data] = {
        headers: self.headers,
        contents: self.contents
    }
    # self.response = Exporter.new(user, {spreadsheet: {headers: self.headers, contents: self.contents}}, messages)
    Invoicing::InventoryLineItem::ImportTemplate.(user, params)
  end

  def validate_item_params(item_params)

  end

  private

  def retrieve_headers
    [
        "Item Name/Description",
        "Item Type",
        "SKU",
        "Item Number",
        "Category ID",
        "HSN/SAC",
        "Rate",
        "Discount %",
        "Tax Rate ID",
        "Note",
        "Status"
    ]
  end

  def add_error(string)
    self.has_errors = true
    if string.present?
      string.to_s + "---error---"
    else
      "---error---"
    end
  end
end