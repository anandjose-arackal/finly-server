class Docs::P2P::Agreements::Index < IndexBuilder::API
  include DynamicAttributes

  resolver 'agreements.default'
  reference '{{record.id}}'

  # Fixed column is always default true
  column :title, label: 'Title', fixed: true, sort: true do
    text value: :title, format: 'primary'
  end

  column :agreement_id, label: "Agreement ID", sort: :order_number, default: true do
    text value: :agreement_id, format: 'primary'
  end

  column :agreement_date, default: true, sort: true do
    date value: :agreement_date
  end

  column :execution_date, default: true, sort: true do
    date value: :execution_date
  end

  column :expiration_date, default: true, sort: true do
    date value: :expiration_date
  end

  column :does_not_expire, default: true, sort: :no_expiration do
    checkbox value: :no_expiration
  end

  column :note, default: false do
    text value: :note
  end

  column :created_at, sort: true do
    date value: :created_at
  end

  column :updated_at, sort: true do
    date value: :updated_at
  end

  column :submitted_at, sort: true do
    date value: :submitted_at
  end

  column :approved_at, sort: true do
    date value: :approved_at
  end

  column :policy, default: true, includes: [:policy] do
    text value: "{{record.policy.name}}"
  end

  column :created_by, default: true, includes: [:created_by] do
    user value: :created_by
  end

  column :status, default: true, sort: :status_id, includes: [:status] do
    indicator value: :agreement_status, format: :agreement_status_format
  end

  IndexBuilder::API::ColumnTemplate::ControllingUser(self)
  IndexBuilder::API::ColumnTemplate::ControllingLevel(self)
  IndexBuilder::API::ColumnTemplate::ReviewProgress(self)

  column :maximum_amount, default: true, includes: [total_amount: :currency] do
    amount :total_amount
  end

  counter -> (user, collection) do
    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :with_status_id
    counts = collection.group(:status_id).count
    counter.add nil, "All", counts.values.reduce(0, :+)

    # Open - open/retracted
    counter.add 90, 'Open', (
    counts[PaymentAgreementStatus.id_for(:draft)].to_i +
        counts[PaymentAgreementStatus.id_for(:retracted)].to_i
    )

    # Awaiting Approval
    if user.has_permission?(awaiting_approval_roles)
      counter.add 91, 'Awaiting Approval',
                  PaymentAgreement.awaiting_action_items(user).count
    end

    # Processing
    counter.add PaymentAgreementStatus.id_for(:awaiting_approval), "Processing", counts[PaymentAgreementStatus.id_for(:awaiting_approval)].to_i

    # Pending Payment - approved/auto_approved/partially_paid/unpaid/initiated
    counter.add 92, 'Active', (
    counts[PaymentAgreementStatus.id_for(:approved)].to_i +
        counts[PaymentAgreementStatus.id_for(:auto_approved)].to_i +
        counts[PaymentAgreementStatus.id_for(:invoice_created)].to_i +
        counts[PaymentAgreementStatus.id_for(:payment_ticket_created)].to_i +
        counts[PaymentAgreementStatus.id_for(:revised)].to_i
    )

    [:rejected, :closed, :terminated].each do |status|
      counter.add PaymentAgreementStatus.id_for(status), status.to_s.titleize, counts[PaymentAgreementStatus.id_for(status)].to_i
    end

    counter
  end

  def self.awaiting_approval_roles
    [:payment_agreement_reviewer, :admin]
  end

  def self.agreement_status(context)
    return 'Processing' if context[:record].status_id == PaymentAgreementStatus.id_for(:awaiting_approval) and not context[:record].controlling_user?(context[:user])

    context[:record].status&.name&.titleize
  end

  def self.agreement_status_format(context)
    case context[:record].status&.name&.to_s&.to_sym
    when :rejected, :terminated
      format = 'danger'
    when :approved, :closed, :auto_approved, :closed, :invoice_created, :payment_ticket_created
      format = 'success'
    when :awaiting_approval
      if context[:record].controlling_user?(context[:user])
        format = 'warning'
      else
        format = 'info'
      end
    when :draft, :retracted
      format = 'info'
    when :revised
      format = 'warning'
    else
      format = 'info'
    end
    format
  end

end