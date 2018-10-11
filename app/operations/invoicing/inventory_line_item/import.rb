class Invoicing::InventoryLineItem::Import < Invoicing::InventoryLineItem::Base

  attr_accessor :company, :inventory_data, :file, :headers, :data, :contents

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

    self.inventory_data = ImportUtil.load_spreadsheet(file, [:description, :sku, :item_code, :category_id, :hsn_sac, :rate, :discount, :tax_rate_id, :note], {skip_empty_lines: true})

    self.headers = retrieve_headers
    self.contents = []
  end

  def validate
    if self.inventory_data.blank?
      add_message :error, "Empty spreadsheet uploaded"
    end
  end

  def process
    self.inventory_data.each do |data|
      content = data.values
      inventory_line_item = user.company.inventory_line_items.build(data)
      if inventory_line_item.save
        content << "Success"
      else
        content << inventory_line_item.errors.full_messages.to_sentence
      end

      self.contents << content
    end
  end

  def success
    self.response = Exporter.new(user, {spreadsheet: {headers: self.headers, contents: self.contents}}, messages)
  end

  private

  def retrieve_headers
    [
        "Item Name/Description",
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
end