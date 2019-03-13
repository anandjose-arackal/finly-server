class Procurements::Mailers::SendMail < Procurements::Mailers::Base
  attr_accessor :workflow_output

  def process
    super

    case self.document.class.name
    when 'PurchaseOrder'
      procurement = self.document&.procurement
      status_tag = StatusTag.find_by(id: StatusTag.id_for(:po_sent))
      unless procurement.status_tags.include? status_tag
        procurement.status_tags << status_tag
      end
      # self.document.update(purchase_order_status_id: PurchaseOrderStatus.id_for(:sent_to_vendor))
      params[:document] = self.document
      params[:aasm_event] = 'send_to_vendor'
      params[:violation_present] = false #todo Check violations
      op = WorkflowManager::Base.(user, params)
      unless op.success?
        add_message :error, op.messages[:error]
      end
      self.workflow_output = op.workflow_output

    end
  end

end