class WorkflowManager::Base < BaseOperation
  attr_accessor :document, :aasm_document, :violations_present, :aasm_event, :document_types, :note
  def init
    self.document = params[:document]
    self.violations_present = params[:violations_present]
    self.aasm_event = params[:aasm_event]
    self.note = params[:note]

    document_class_name = self.document&.class&.name

    case document_class_name
      when 'PurchaseOrder'
        self.aasm_document = ::WorkflowManager::Aasm::PurchaseOrderProvider.new self.document, violations_present, user
      when 'Invoice'
        self.aasm_document = ::WorkflowManager::Aasm::InvoiceProvider.new self.document, violations_present, user
      when 'Report'
        self.aasm_document = ::WorkflowManager::Aasm::ReportProvider.new self.document, violations_present, user
      when 'MoneyRequest'
        self.aasm_document = ::WorkflowManager::Aasm::MoneyRequestProvider.new self.document, violations_present, user
      when 'TravelRequest'
        self.aasm_document = ::WorkflowManager::Aasm::TravelRequestProvider.new self.document, violations_present, user
      else
        add_message :error, 'Unknown document type'
    end
  end

  def validate
    # Check if it can run
    # doable events are all the events which are possible at the current state; provided by AASM
    doable_events = self.aasm_document.aasm.events.map(&:name)
    unless doable_events.include?(self.aasm_event.to_sym)
      add_message :error, 'Cannot perform this action at this state'
      return
    end
  end

  def process
    # Run event
    action = self.aasm_document.send(self.aasm_event)
    unless action
      add_message :error, "Couldn't perform action"
      return
    end

    # Create Trail
    trail = document.trails.new action_user: user,
                           action_id: TrailAction.id_for(aasm_event),
                           action_level_id: aasm_document.current_level&.id,
                           modified_level_id: aasm_document.next_level&.id

    if self.note.present?
      trail.note = self.note
    end

    trail.save
    # Return Data to referrer
  end

  def success
    params[:workflow_output] = {
        action_user: user,
        action_id: TrailAction.id_for(aasm_event),
        action_level_id: aasm_document.current_level&.id,
        modified_level_id: aasm_document.next_level&.id
    }

   WorkflowManager::Base::BasePresenter.new(user, params, messages)
  end

  class WorkflowManager::Base::BasePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :workflow_output

    def init
      self.workflow_output = params[:workflow_output]
    end
  end
end