class WorkflowManager::PurchaseOrder < WorkflowManager::Base
  attr_accessor :document, :aasm_document, :violations_present, :aasm_event, :document_types
  def init
    self.document_types = %w( report money_request purchase_order )
    document_type = params[:workflow_document_type]

    unless document_types.include?(document_type)
      add_message :error, 'Unknown document type'
      return
    end

    self.document = params[:document]
    self.violations_present = params[:violations_present]
    self.aasm_event = params[:aasm_event]

    case document_type
      when 'purchase_order'
        self.aasm_document = ::WorkflowManager::Aasm::PurchaseOrder.new self.document, violations_present, user

      else
        add_message :error, 'Unknown document type'
    end

  end

  def validate

  end

  def process
    # Check if it can run
    action = 'may_' + aasm_event + '?'
    may_run = self.aasm_purchase_order.send(action)
    debugger

    # Run event

    # Create Trail

    # Return Data to referrer


  end

  def get_work_flow_class

  end
end