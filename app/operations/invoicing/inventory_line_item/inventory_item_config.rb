class Invoicing::InventoryLineItem::InventoryItemConfig < Invoicing::InventoryLineItem::Base

  attr_accessor :categories, :tax_rates

  def init
    self.categories = user.company.categories.inward_invoice_line_items_only
    self.tax_rates = user.company.tax_rates
  end

  def success
    params[:categories] = self.categories
    params[:tax_rates] = self.tax_rates
    Invoicing::InventoryLineItem::InventoryItemConfig::ConfigPresenter.new(user, params, messages)
  end

  class Invoicing::InventoryLineItem::InventoryItemConfig::ConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :categories, :tax_rates

    def init
      self.categories = params[:categories]
      self.tax_rates = params[:tax_rates]
    end
  end
end