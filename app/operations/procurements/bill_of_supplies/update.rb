class Procurements::BillOfSupplies::Update < Procurements::BillOfSupplies::Base
  attr_accessor :bill_of_supply, :procurement, :bill_of_supply_params, :purchase_order, :id_old_attachments,
                :id_current_attachments
  def init
    procurement_id = params[:procurement_id]
    self.procurement = user.company.procurements.find_by id: procurement_id
    bill_of_supply_id = params[:id] || params[:bill_of_supply_id]
    self.bill_of_supply = procurement.bill_of_supplies.find_by id: bill_of_supply_id
    self.bill_of_supply_params = bill_of_supply_parameters
    self.purchase_order = self.procurement&.purchase_order
  end

  def validate
    unless self.bill_of_supply.present?
      add_message :error, 'Bill Of Supply not found'
      return
    end
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found for this procurement, cannot create GRN'
      return
    end
  end

  def pre_process
    self.id_current_attachments = user.company.procurement_attachments.with_id(bill_of_supply_params[:attachments])
    self.bill_of_supply_params.delete(:attachments)
    self.id_old_attachments = self.bill_of_supply.attachments
  end

  def process
    self.bill_of_supply.assign_attributes(bill_of_supply_params)
    if bill_of_supply.valid?

      # purchase_order.save
      bill_of_supply.save
    else
      add_message :error, bill_of_supply.errors.full_messages
      return
    end

    self.id_old_attachments.update_all(procurement_document_id: nil, procurement_document_type: nil)

    self.id_current_attachments.update_all(procurement_document_id: bill_of_supply.id, procurement_document_type: bill_of_supply.class.name)

  end

  def post_process
    add_message :success, 'Successfully updated Bill Of Supply'
  end

  private

  def bill_of_supply_parameters
    params.require(:bill_of_supply).permit(:id, :doc_number, :location_id, :delivery_location_id, :vendor_id, :payment_term_id, :procurement_term_id, :date, :bill_date,
                                           :transaction_date, :due_date,
                                       amount_attributes: [:value, :currency_id],
                                       items_attributes: [:id, :description, :hsn_sac, :quantity, :rate, :tax, :discount,
                                                          :delivery_date, :comment,
                                                          tax_amount_attributes: [:value, :currency_id], discount_amount_attributes: [:value, :currency_id],
                                                          total_amount_attributes: [:value, :currency_id]
                                       ],
                                       attachments: []
    )

  end

end