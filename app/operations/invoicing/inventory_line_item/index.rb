class Invoicing::InventoryLineItem::Index < Invoicing::InventoryLineItem::Base

  attr_accessor :inventory_line_items

  class Invoicing::InventoryLineItem::Index::InventoryLineItemsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :inventory_line_items, :paginated_line_items

    has_scope :search
    has_scope :filter_category_id
    has_scope :filter_item_type, type: :array

    def init
      self.inventory_line_items = apply_scopes(params[:inventory_line_items], params)
      per_page = params[:per_page] || 30
      self.paginated_line_items = self.inventory_line_items.paginate(page: params[:page], per_page: per_page)
    end
  end

  def init
    self.inventory_line_items = user.company.inventory_line_items
  end

  def validate

  end

  def success
    params[:inventory_line_items] = self.inventory_line_items
    Invoicing::InventoryLineItem::Index::InventoryLineItemsPresenter.new(user, params, messages)
  end

end