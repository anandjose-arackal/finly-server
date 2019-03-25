class Procurements::EWayBills::Update < Procurements::EWayBills::Base
  attr_accessor :e_way_bill, :procurement, :e_way_bill_params, :purchase_order, :id_old_attachments,
                :id_current_attachments
  def init
    procurement_id = params[:procurement_id]
    self.procurement = user.company.procurements.find_by id: procurement_id
    e_way_bill_id = params[:id] || params[:e_way_bill_id]
    self.e_way_bill = procurement.e_way_bills.find_by id: e_way_bill_id
    self.e_way_bill_params = e_way_bill_parameters
    self.purchase_order = self.procurement&.purchase_order
  end

  def validate
    unless self.e_way_bill.present?
      add_message :error, 'E Way Bill not found'
      return
    end
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found for this procurement, cannot create GRN'
      return
    end
  end

  def pre_process
    self.id_current_attachments = user.company.procurement_attachments.with_id(e_way_bill_params[:attachments])
    self.e_way_bill_params.delete(:attachments)
    self.id_old_attachments = self.e_way_bill.attachments
  end

  def process
    self.e_way_bill.assign_attributes(e_way_bill_params)
    if e_way_bill.valid?

      # purchase_order.save
      e_way_bill.save
    else
      add_message :error, e_way_bill.errors.full_messages
      return
    end

    self.id_old_attachments.update_all(procurement_document_id: nil, procurement_document_type: nil)

    self.id_current_attachments.update_all(procurement_document_id: e_way_bill.id, procurement_document_type: e_way_bill.class.name)

  end

  def post_process
    add_message :success, 'Successfully updated E Way Bill'
  end

  private

  def e_way_bill_parameters
    params.require(:e_way_bill).permit(:id, :doc_number, :date, :generated_by, :valid_from, :valid_to, :ref_doc_name, :ref_doc_date,
                                       :location_id, :delivery_location_id,
                                       :hsn_code, :reason_for_transportation, :mode, :vehicle_number,
                                       amount_attributes: [:value, :currency_id],
                                       items_attributes: [:id, :description, :hsn_sac, :quantity, :rate, :tax, :discount,
                                                          :delivery_date, :comment,
                                       tax_amount_attributes: [:value, :currency_id], discount_amount_attributes: [:value, :currency_id],
                                       total_amount_attributes: [:value, :currency_id]
                                       ],
                                       attachments: []
    )

  end

  # def update_purchase_order_item(item)
  #   purchase_order_item = self.purchase_order.items.find_by id: item.purchase_order_item_id
  #
  #   po_item_params = {
  #       accepted: purchase_order_item.accepted + item.accepted,
  #       rejected: purchase_order_item.rejected + item.rejected,
  #       delivered: purchase_order_item.delivered + item.delivered
  #   }
  #
  #   purchase_order_item.assign_attributes(po_item_params)
  #   purchase_order_item.save
  #
  # end

end