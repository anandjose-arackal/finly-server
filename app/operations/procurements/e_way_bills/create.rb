class Procurements::EWayBills::Create < Procurements::EWayBills::Base
  attr_accessor :e_way_bill, :procurement, :e_way_bill_params, :purchase_order
  def init
    procurement_id = params[:procurement_id]
    self.procurement = user.company.procurements.find_by id: procurement_id
    # self.inward_document_params = inward_document_parameters
    self.purchase_order = self.procurement&.purchase_order
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found for this procurement, cannot create GRN'
      return
    end
  end

  def process
    self.e_way_bill = self.procurement.e_way_bills.build({
                                                             user_id: user.id,
                                                             company_id: user.company.id,
                                                             location_id: self.purchase_order&.location_id,
                                                             delivery_location_id: self.purchase_order&.delivery_location_id,
                                                             vendor_id: self.purchase_order&.vendor_id
                                                         })

    e_way_bill.save

    for item in purchase_order.items
      e_way_bill_item_params = e_way_bill_item_parameters(item)
      e_way_bill_item = self.e_way_bill.items.build(e_way_bill_item_params)
      e_way_bill_item.save
    end
  end

  def success
    params[:e_way_bill] = self.e_way_bill
    Procurements::EWayBills::Create::CreatePresenter.new(user, params, messages)
  end

  class Procurements::EWayBills::Create::CreatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :e_way_bill, :items

    def init
      self.e_way_bill = params[:e_way_bill]
      self.items = e_way_bill.items
    end
  end

  private

  def e_way_bill_item_parameters(po_item)
    #params
    e_way_bill_item_params = {
        purchase_order_item_id: po_item.id,
        inventory_line_item_id: po_item.inventory_line_item_id,
        product_id: po_item.product_id,
        description: po_item.description,
        quantity: po_item.quantity,
        rate: po_item.rate,
        tax: po_item.tax,
        discount: po_item.discount,
        tax_amount_attributes: {
            value: po_item.tax_amount&.value,
            currency_id: po_item.tax_amount&.currency_id
        },
        discount_amount_attributes: {
            value: po_item.discount_amount&.value,
            currency_id: po_item.discount_amount&.currency_id
        },
        total_amount_attributes: {
            value: po_item.total_amount&.value,
            currency_id: po_item.total_amount&.currency_id
        }
    }
  end
end

