class ItemMaster::Item::Exports::Base < ItemMaster::Item::Base
  attr_accessor  :headers, :items

  def init
    self.items= user.company.items.includes_for_export
    self.headers = default_headers
  end

  class ItemMaster::Item::Exports::Base::ExportPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :data, :header, :file_name

    def init
      self.data = params[:data]
      self.header = params[:header]
      self.file_name = params[:export_name]
    end

  end

  private

  def default_headers
    [
        "Item Number",
        "Description",
        "Category",
        "HSNSAC",
        "SKU",
        "Category Name",
        "Tax Rate",
        "Item Rate",
        "Supply Item Type",
        "Item Expense Type",
        "Product Type",
        "Created User"
    ]
  end


  def retrieve_data(item)
    data_arr = []
    data_arr << item.item_number
    data_arr << item.description
    data_arr << item.category&.name
    data_arr << "#{item.tax_rate&.name} #{item.tax_rate&.rate}"
    data_arr << item.rate
    data_arr << item.supply_item_type&.name&.humanize
    data_arr << item.item_expense_type&.name&.humanize
    data_arr << item.product_type&.name&.humanize
    data_arr << "#{item.user&.first_name} #{item.user&.last_name}"
    data_arr
  end
end
