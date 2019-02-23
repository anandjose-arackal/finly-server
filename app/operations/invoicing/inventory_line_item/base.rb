class Invoicing::InventoryLineItem::Base < BaseOperation

  attr_accessor :item, :company

  def init
    id = params[:id] || params[:inventory_line_item_id]
    self.item = ::InventoryLineItem.find_by_id id
    self.company = user.company
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters pass, try again"
      return
    end
  end

  def inventory_item_params
    params.require(:inventory_item).permit(:rate, :tax_rate_id, :tax, :discount, :hsn_sac, :category_id, :description, :sku, :note, :item_code, :account, :supply_item_type_id, artifacts_attributes: [:id, :attachment, :description, :_destroy])
  end

  class Invoicing::InventoryLineItem::Base::ItemPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :inventory_item

    def init
      self.inventory_item = params[:inventory_line_item]
    end

  end
end