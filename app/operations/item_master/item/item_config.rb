class ItemMaster::Item::ItemConfig < ItemMaster::Item::Base

  attr_accessor :categories, :tax_rates, :supply_item_types, :field_configurations

  def init
    self.categories = user.company.categories.inward_invoice_line_items_only.active
    self.tax_rates = user.company.tax_rates
    self.supply_item_types = SupplyItemType.all
    self.field_configurations = user.company.field_configurations.with_parent_type(FieldParentType.id_for(:item))
  end

  def success
    params[:categories] = self.categories
    params[:tax_rates] = self.tax_rates
    params[:supply_item_types] = self.supply_item_types
    params[:field_configurations] = self.field_configurations
    ItemMaster::Item::ItemConfig::ConfigPresenter.new(user, params, messages)
  end

  class ItemMaster::Item::ItemConfig::ConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :categories, :tax_rates, :supply_item_types, :field_configurations

    def init
      self.categories = params[:categories]
      self.tax_rates = params[:tax_rates]
      self.supply_item_types = params[:supply_item_types]
      self.field_configurations = params[:field_configurations]
    end
  end
end