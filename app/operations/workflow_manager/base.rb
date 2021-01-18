class WorkflowManager::Base < BaseOperation
  attr_accessor :document, :aasm_document, :violations_present, :forwarded_to_user,
                :aasm_event, :document_types, :note, :role_id, :provider_name, :trail, :document_class_name,
                :reject_to_user, :reject_to_level,:paper_trail_event
  def init
    self.document = params[:document]
    self.violations_present = params[:violations_present]
    self.aasm_event = params[:aasm_event]
    self.note = params[:note]
    self.forwarded_to_user = params[:forwarded_to_user]
    self.provider_name = params[:provider_name] || self.document.get_default_provider
    self.paper_trail_event = params[:aasm_event].capitalize

    # used for knowing if the document would be rejected to a specific level in the approval chain
    self.reject_to_user = params[:reject_to_user]
    self.reject_to_level = params[:reject_to_level]

    # todo - The below switch case can be reduced to one line since provider name is already present
    self.document_class_name = self.document&.class&.name

    workflow_input = {
      violations_present: violations_present,
      document: document,
      provider_name: provider_name,
      forwarded_to_user: forwarded_to_user,
      reject_to_level: reject_to_level,
      reject_to_user: reject_to_user
    }

    case self.document_class_name
    when 'PurchaseOrder'
      self.aasm_document = ::WorkflowManager::Aasm::PurchaseOrderProvider.new user, workflow_input
    when 'Invoice'
      if provider_name == 'PoInvoiceProvider'
        self.aasm_document = ::WorkflowManager::Aasm::PoInvoiceProvider.new user, workflow_input
      elsif provider_name == 'NonPoInvoiceProvider'
        self.aasm_document = ::WorkflowManager::Aasm::NonPoInvoiceProvider.new user, workflow_input
      elsif provider_name == 'AgreementInvoiceProvider'
        self.aasm_document = ::WorkflowManager::Aasm::AgreementInvoiceProvider.new user, workflow_input
      end
    when 'Report'
      self.aasm_document = ::WorkflowManager::Aasm::ReportProvider.new user, workflow_input
    when 'MoneyRequest'
      if provider_name == 'TravelRequestProvider'
        self.aasm_document = ::WorkflowManager::Aasm::MoneyRequestProvider.new user, workflow_input
      else
        self.aasm_document = ::WorkflowManager::Aasm::MoneyRequestProvider.new user, workflow_input
      end
    when 'TravelRequest'
      if provider_name == 'TravelRequestBookingProvider'
        self.aasm_document = ::WorkflowManager::Aasm::TravelRequestBookingProvider.new user, workflow_input
      else
        self.aasm_document = ::WorkflowManager::Aasm::TravelRequestProvider.new user, workflow_input
      end
    when 'BankPaymentRequest'
      self.aasm_document = ::WorkflowManager::Aasm::BankPaymentRequestProvider.new user, workflow_input
      # self.aasm_document = ::WorkflowManager::Aasm::BankPaymentRequestProvider.new self.document, violations_present, user
    when 'PurchaseRequest'
      self.aasm_document = ::WorkflowManager::Aasm::PurchaseRequestProvider.new user, workflow_input
    when 'PurchaseRequestItem'
      self.aasm_document = ::WorkflowManager::Aasm::PurchaseRequestItemProvider.new user, workflow_input
    when 'YesBankVendor'
      self.aasm_document = ::WorkflowManager::Aasm::YesBankVendorProvider.new user, workflow_input
    when 'PaymentAgreement'
      self.aasm_document = ::WorkflowManager::Aasm::PaymentAgreementProvider.new user, workflow_input
    when 'BbpsBillerSubscription'
      self.aasm_document = ::WorkflowManager::Aasm::BbpsBillerSubscriptionProvider.new user, workflow_input
    when 'BbpsBill'
      self.aasm_document = ::WorkflowManager::Aasm::BbpsBillProvider.new user, workflow_input
    when 'CreditNote'
      self.aasm_document = ::WorkflowManager::Aasm::CreditNoteProvider.new user, workflow_input
    else
      add_message :error, 'Unknown document type'
    end

    self.role_id = params[:role_id]
    if self.role_id.blank? and params[:view].present?
      self.role_id = UserRole::VALUES[params[:view].to_sym]
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

    if action
      add_message :success, self.aasm_document.messages[:success]
    elsif self.aasm_document.messages[:error].present?
      add_message :error, self.aasm_document.messages[:error]&.first
      return
    else
      add_message :error, "Couldn't perform action"
      return
    end
    # If user delegation is allowed
    delegated_action_user_id = actual_current_user.present? ? actual_current_user.id : nil
    if self.document_class_name == "PurchaseOrder"
      # if self.document.procurement.po_revisions.present? 
      if self.document.procurement.po_revisions.pluck(:id).include?(self.document.id)
        note = "Revised PO # #{self.document.po_number}, #{aasm_event.humanize}"
      end
    end
 
    # Create Trail
    self.trail = document.trails.new action_user: user,
                           action_id: TrailAction.id_for(aasm_event),
                           action_user_role_id: role_id,
                           action_level_id: aasm_document.current_level&.id,
                           modified_level_id: aasm_document.new_level&.id,
                           delegated_action_user_id: delegated_action_user_id,
                           note: note

    if self.note.present?
      self.trail.note = "\n#{self.note}"
    end

    self.trail.save
    # Return Data to referrer

    if self.document_class_name == "PurchaseOrder" && self.document.status.name == "auto_approved"
        document.trails.create action_user: user,
                         action_id: TrailAction.id_for('auto_approve'),
                         action_user_role_id: role_id,
                         action_level_id: aasm_document.current_level&.id,
                         modified_level_id: aasm_document.new_level&.id,
                         delegated_action_user_id: delegated_action_user_id,
                         note: note
    end

  end

  def success
    params[:workflow_output] = {
        action_user: user,
        action_id: TrailAction.id_for(aasm_event),
        action_level_id: aasm_document.current_level&.id,
        modified_level_id: aasm_document.next_level&.id,
        role_id: self.role_id,
        trail: self.trail
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
