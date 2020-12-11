class AuditTrailExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :item_type, record_attribute: true
  attribute :item_id, record_attribute: true
  attribute :created_by, record_attribute: true, exposure: true
  attribute :event, record_attribute: true
  attribute :user_ip, record_attribute: true
  attribute :user_agent, record_attribute: true
  attribute :company_id, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :transaction_id, record_attribute: true
  attribute :user_transaction_id, record_attribute: true
  attribute :event_name do
    case record.event.downcase
    when 'update', 'approve', 'un approve', 'create'
      "#{record.event.capitalize}d"
    when  'reject','retract'
      "#{record.event}ed"
    when  'return control'
      "Returned Control of"
    when 'took control'
      "Took Control of"
    when 'submit'
      "Submitted"
    else
      record.event
    end
  end
  attribute :document_number do
    record.get_document_number
  end
  attribute :parent_document_type, record_attribute: true
  attribute :changes do
    record.get_change_statement
  end

  attribute :changes_less do
    record.changes_less
  end

  attribute :item_type_label do
    "#{record.item_type} Changes"
  end

  attribute :description do
    case record.event.downcase
    when 'update', 'approve', 'un approve', 'create'
      event_name = "#{record.event.capitalize}d"
    when  'reject','retract'
      event_name ="#{record.event}ed"
    when  'return control'
      event_name ="Returned Control of"
    when 'took control'
      event_name ="Took Control of"
    when 'submit'
      event_name ="Submitted"
    else
      event_name =record.event
    end

    case record.event.downcase
    when 'vendor confirmed'
      "#{record.created_by.name} the Purchase Order as Vendor Confirmed"
    when 'send to vendor'
      "#{record.created_by.name} Sent Purchase Order to Vendor"
    else
      "#{record.created_by.name} #{event_name} #{record.item_type}"
    end
  end

end