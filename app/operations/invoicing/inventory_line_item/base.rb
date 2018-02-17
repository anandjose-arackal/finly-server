class Invoicing::InventoryLineItem::Base < BaseOperation

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invaoid parameters pass, try again"
      return
    end
  end

  def inventory_item_params
    params.require(:inventory_item).permit(:rate, :tax, :discount, :hsn_sac, :category_id, :description)
  end
end