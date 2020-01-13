class ItemMaster::Item::Exports::Base < ItemMaster::Item::Base
  attr_accessor  :headers, :items

  def init
    ids = params[:ids] || params[:item_ids]
    unless ids.is_a?(Array) or ids.blank?
      ids = ids.split(',')
    end
    self.items = user.company.items.non_deleted.includes_for_export
    self.items = self.items.where(id: ids) if ids.present?
    self.headers = default_headers
  end

  class ItemMaster::Item::Exports::Base::ExportPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :data, :header, :file_name, :result_file_path

    def init
      self.data = params[:data]
      self.header = params[:header]
      self.file_name = params[:export_name]
      self.result_file_path = params[:result_file_path]
    end

  end

  private

  def default_headers
    [
        "Item Number",
        "GL Code",
        "Description",
        "Product Type",
        "Active",
        "Category",
        "HSN/SAC",
        "SKU",
        "Expense Type",
        "TDS Applicable",
        "Tax Rate(name - rate)",
        "Item Rate",
        "Supply Item Type",
        "Created User(firstname - lastname)",
        "Created At(dd-mm-yyyy)"
    ]
  end


  def retrieve_data(item)
    data_arr = []
    data_arr << item.item_number
    data_arr << item.item_code
    data_arr << item.description
    data_arr << item.product_type&.name&.humanize
    data_arr << item.active
    data_arr << item.category&.name
    data_arr << item.hsn_sac
    data_arr << item.sku
    data_arr << item.item_expense_type&.name&.humanize
    data_arr << item.tds_applicable
    data_arr << "#{item.tax_rate&.name} - #{item.tax_rate&.rate}"
    data_arr << item.rate
    data_arr << item.supply_item_type&.name&.humanize
    data_arr << "#{item.user&.first_name} #{item.user&.last_name}"
    data_arr << item.created_at.strftime('%d-%b-%Y')
    data_arr
  end
end
