class ItemMaster::Item::ItemConfig < ItemMaster::Item::Base

  attr_accessor :categories, :tax_rates, :supply_item_types, :filter_categories

  def init
    self.categories = user.company.categories.inward_invoice_line_items_only.leaves
    self.filter_categories = user.company.categories.inward_invoice_line_items_only
    self.tax_rates = user.company.tax_rates
    self.supply_item_types = SupplyItemType.all
  end

  def success
    params[:categories] = self.categories
    params[:tax_rates] = self.tax_rates
    params[:supply_item_types] = self.supply_item_types
    params[:filter_categories] = self.filter_categories
    ItemMaster::Item::ItemConfig::ConfigPresenter.new(user, params, messages)
  end

  class ItemMaster::Item::ItemConfig::ConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :categories, :tax_rates, :supply_item_types, :filter_categories

    def init
      self.categories = params[:categories]
      self.tax_rates = params[:tax_rates]
      self.supply_item_types = params[:supply_item_types]
      self.filter_categories = params[:filter_categories]
    end
  end
end