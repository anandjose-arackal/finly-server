class Procurements::Mailers::SendMail < Procurements::Mailers::Base

  def process
    super

    case self.document.class.name
      when 'PurchaseOrder'
        procurement = self.document&.procurement
        status_tag = StatusTag.find_by(id: StatusTag.id_for(:po_sent))
        unless procurement.status_tags.include? status_tag
          procurement.status_tags << status_tag
        end
        self.document.update(purchase_order_status_id: PurchaseOrderStatus.id_for(:sent_to_vendor))

    end
  end
end