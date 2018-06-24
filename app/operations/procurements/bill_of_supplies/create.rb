class Procurements::BillOfSupplies::Create < Procurements::BillOfSupplies::Base
  attr_accessor :purchase_order, :procurement, :bill_of_supply, :bill_of_supply_params

  def init
    # self.bill_of_supply_params = bill_of_supply_parameters

    self.procurement = user.company.procurements.find_by id: params[:procurement_id]
    self.purchase_order = self.procurement&.purchase_order
  end

  def validate
    unless self.procurement.present?
      add_message :error, 'Procurement not found'
      return
    end

    unless self.purchase_order.present?
      add_message :error, 'Purchase order not found'
    end
  end

  def process
    self.bill_of_supply = self.procurement.bill_of_supplies.build

    self.bill_of_supply.user = user
    self.bill_of_supply.company = user.company

    if bill_of_supply.valid?
      purchase_order.save

      purchase_order.items.each do |item|
        bill_of_supply_item_params = bill_of_supply_item_params(item)
        bill_of_supply_item = bill_of_supply.items.build(bill_of_supply_item_params)
        bill_of_supply_item.save
      end
      add_message :success, 'Successfully created Bill of Supply'
    else
      add_message :error, purchase_order.errors.full_messages
    end
  end

  def success
    params[:bill_of_supply] = self.bill_of_supply
    Procurements::BillOfSupplies::Create::CreatePresenter.new(user, params, messages)

  end

  class Procurements::BillOfSupplies::Create::CreatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :bill_of_supply, :items

    def init
      self.bill_of_supply = params[:bill_of_supply]
      self.items = bill_of_supply.items
    end

  end

  def bill_of_supply_item_params(po_item)
    inward_item_params = {
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