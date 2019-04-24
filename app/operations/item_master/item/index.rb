class ItemMaster::Item::Index < ItemMaster::Item::Base

  attr_accessor :inventory_line_items

  class ItemMaster::Item::Index::InventoryLineItemsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :inventory_line_items, :paginated_line_items, :offset

    has_scope :search
    has_scope :filter_category_id
    has_scope :filter_item_type, type: :array #todo undo this after implementation
    has_scope :filter_active

    def init
      self.inventory_line_items = apply_scopes(params[:inventory_line_items], params)
      per_page = params[:per_page] || 30
      self.paginated_line_items = self.inventory_line_items&.order(created_at: :desc)&.paginate(page: params[:page], per_page: per_page)
    end
  end

  def init
    if user.has_policy_role?(UserRole.id_for(:item_master_manager)) || user.vp_admin_or_auditor? || user.is_purchase_request_initiator?
      self.inventory_line_items = user.company.items
    end
  end

  def validate
    if inventory_line_items.blank?
      add_message :error, 'No record found'
    end
  end

  def success
    params[:inventory_line_items] = self.inventory_line_items
    ItemMaster::Item::Index::InventoryLineItemsPresenter.new(user, params, messages)
  end

end