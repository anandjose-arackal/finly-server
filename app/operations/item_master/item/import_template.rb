# now that the import should include custom fields that belong to a particular company,
# it will need to be dynamically generated
class ItemMaster::Item::ImportTemplate < ItemMaster::Item::Base

  attr_accessor :company, :inventory_item_custom_fields, :sample_type,
                :headers, :content, :sheets, :import_data

  def init
    self.company = user.company
    # self.payment_order_custom_fields = self.company.field_configurations.non_deleted.with_field_parent_type(FieldParentType.id_for(:invoice))
    # self.sample_type = params[:sample_type]

    if params[:import_data].present?
      self.import_data = params[:import_data]
    end
  end

  def process
    self.headers = default_headers
    self.content = []
    # todo change below for getting inventory line item custom fields
    # self.payment_order_custom_fields.each do |custom_field_config|
    #   case custom_field_config.field_type_id
    #     when FieldType.id_for(:drop_down), FieldType.id_for(:multiselect)
    #       self.headers << "#{custom_field_config.field_name} ID"
    #     else
    #       self.headers << "#{custom_field_config.field_name}"
    #   end
    # end
    self.sheets = [
        {
            item_headers: self.headers,
            item_contents: import_data.present? ? import_data[:contents] : []
        }
    ]
    # adding Categories to the excel sheet
    category_headers = ["ID", "Category Name"]
    category_contents = []

    # todo only fetch categories for collect and vendor payments line items
    user.company.categories.active.each do |category|
      category_contents << [category.id, category.name]
    end
    self.sheets << {
        item_headers: category_headers,
        item_contents: category_contents,
        name: "Categories",

    }

    # adding Tax Rates to the Excel sheet
    tax_rate_headers = ["ID", "Tax Rate Name", "Rate %", "Internal ID"]
    tax_rate_contents = []
    user.company.tax_rates.each do |tax_rate|
      tax_rate_contents << [tax_rate.id, tax_rate.name, tax_rate.rate, tax_rate.internal_id]
    end
    self.sheets << {
        item_headers: tax_rate_headers,
        item_contents: tax_rate_contents,
        name: "Tax Rates"
    }


    # Adding Item Types

    item_types = SupplyItemType.all
    item_type_headers = ["ID", "Item Type"]
    item_type_contents = []
    item_types.each do |item_type|
      item_name = item_type.name.humanize.split(" ").map(&:capitalize).join(" ")
      item_type_contents << [item_type.id, item_name]
    end
    self.sheets << {
        item_headers: item_type_headers,
        item_contents: item_type_contents,
        name: "Item Types"
    }

    # adding custom fields to the excel sheet
    # self.payment_order_custom_fields.with_field_type([FieldType.id_for(:drop_down), FieldType.id_for(:multiselect)]).each do |custom_field_config|
    #   custom_field_headers = ["#{custom_field_config.field_name} ID", "#{custom_field_config.field_name} Name"]
    #   case custom_field_config.field_type_id
    #     when FieldType.id_for(:drop_down)
    #       selection_items = custom_field_config.drop_down_items
    #     when FieldType.id_for(:multiselect)
    #       selection_items = custom_field_config.multiselect_items
    #     else
    #       selection_items = []
    #   end
    #   custom_field_contents = []
    #   selection_items.each do |content|
    #     custom_field_contents << [content.id, content.name]
    #   end
    #   self.sheets << {
    #       item_headers: custom_field_headers,
    #       item_contents: custom_field_contents,
    #       name: custom_field_config.field_name
    #   }
    # end
  end

  def success
    self.response = Exporter.new(user, {spreadsheet: {headers: self.headers, contents: self.content, sheets: self.sheets, template: 'export_template/template_w_validation'}}, messages)
  end

  private

  def default_headers
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
        "Note"
    ]
  end
end