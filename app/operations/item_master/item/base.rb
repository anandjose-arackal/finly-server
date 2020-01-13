class ItemMaster::Item::Base < BaseOperation

  attr_accessor :item, :company, :custom_fields

  def init
    id = params[:id] || params[:inventory_line_item_id]
    self.item = ::Item.non_deleted.find_by_id id
    self.company = user.company
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters pass, try again"
      return
    end
  end

  def inventory_item_params
    params.require(:inventory_item).permit(:rate, :unit_of_measurement, :tax_rate_id, :tax, :discount, :hsn_sac, :category_id, :description, :sku, :note, :item_code, :active, :account, :item_expense_type_id, :supply_item_type_id, :product_type_id, :item_number, :override_item_number, :tds_applicable, artifacts_attributes: [:id, :attachment, :_destroy])
  end

  class ItemMaster::Item::Base::ItemPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :inventory_item

    def init
      self.inventory_item = params[:inventory_line_item]
    end

  end

  def validate_custom_fields(save=false)
    set_fields = set_custom_fields self.item, self.custom_fields, save
    unless set_fields.success?
      add_message :error, set_fields.messages[:error]
      return
    end
    valid = CustomField::Validate.(self.item)
    unless valid.success?
      add_message :error, valid.messages[:error]
      return
    end
  end

  def set_custom_fields(item, data, save)
    custom_fields = {custom_fields: data}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(item, FieldParentType.id_for(:item), custom_fields)
  end
end