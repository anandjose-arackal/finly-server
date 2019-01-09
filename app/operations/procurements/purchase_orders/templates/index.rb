class Procurements::PurchaseOrders::Templates::Index < Procurements::PurchaseOrders::Templates::Base
  attr_accessor :po_templates

  def pre_validate
    user_present? and params_present?
  end

  def init
    self.po_templates = user.purchase_order_templates
  end

  def success
    params[:po_templates] = self.po_templates
    Procurements::PurchaseOrders::Templates::Index::SuccessPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::Templates::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :po_templates, :count, :paginated_po_templates

    def init
      self.po_templates = params[:po_templates]
      self.paginated_po_templates = self.po_templates.paginate(per_page: params[:per_page], page: params[:page])
      self.count = self.po_templates.count
    end

  end

end