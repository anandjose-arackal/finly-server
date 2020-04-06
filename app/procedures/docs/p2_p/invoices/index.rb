class Docs::P2P::Invoices::Index < IndexBuilder::API
  include DynamicAttributes

  counter -> (user, collection) do
    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :with_status_id
    counts = collection.group(:invoice_status_id).count
    counter.add nil, "All", counts.values.reduce(0, :+)
    if user.has_permission?(awaiting_approval_roles)
      counter.add 99, 'Awaiting Approval',
                  collection.where(invoice_status_id: InwardInvoiceStatus.id_for(:processing), controlling_user_id: user.id).count
    end
    InwardInvoiceStatus.all.each do |status|
      counter.add status.id, status.name.humanize, counts[status.id]
    end
    counter
  end

  def self.awaiting_approval_roles
    raise "Role is not defined"
  end

  def self.cost_center_name(user, record, record_exposure)
    return "Multiple" if record_exposure.cost_allocation_items

    record_exposure.cost_center&.name
  end

  def self.department_name(user, record, record_exposure)
    return "Multiple" if record_exposure.cost_allocation_items

    record_exposure.department&.name
  end

  def self.format_status(user, record, record_exposure)
    case record.status&.name&.to_s&.to_sym
    when :rejected
      format = 'danger'
    when :paid, :approved, :closed, :auto_approved
      format = 'success'
    when :processing
      if record.controlling_user_id == user
        format = 'warning'
      else
        format = 'info'
      end
    when :open, :retracted, :pending, :voided, :initiated
      format = 'info'
    when :unpaid, :partially_paid
      format = 'warning'
    else
      format = 'danger'
    end
    format
  end
end