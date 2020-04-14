class Docs::PaymentTickets::Payments::Index < IndexBuilder::API
  include DynamicAttributes

  resolver 'payments.default'
  reference '{{record.payment_order.bank_payment_request.id}}'

  # Fixed column is always default true
  column :id, label: 'Payment ID', fixed: true, sort: :id do
    text value: "{{record.id}}", format: 'primary'
  end

  column :ticket_id, label: "Payment Ticket ID", sort: :payment_order_id, default: true do
    text value: "{{record.payment_order_id}}"
  end

  column :created_at, sort: :created_at do
    date value: :created_at
  end

  column :submitted_at do
    date value: -> (context) { context[:record].payment_order.bank_payment_request.submitted_at }
  end

  column :approved_at do
    date value: -> (context) { context[:record].payment_order.bank_payment_request.approved_at }
  end

  column :scheduled_date, sort: :payment_order_scheduled_at, default: true, includes: [:payment_order] do
    date value: -> (context) { context[:record].payment_order.scheduled_at }
  end

  column :created_by, default: true, includes: [payment_order: {bank_payment_request: :created_by}] do
    user value: -> (context) { context[:record].payment_order.bank_payment_request.created_by }
  end

  column :status, default: true, includes: [:status] do
    badge value: "{{record.status.name}}", format: :format_status
  end

  column :policy, default: true, includes: [payment_order: {bank_payment_request: :policy}] do
    text value: "{{record.payment_order.bank_payment_request.policy.name}}"
  end

  column :payment_amount, default: true, includes: {amount: :currency} do
    amount value: :amount
  end

  # column :progress, label: 'Approval Progress', default: true, includes: [:dlrms] do
  #   progress_bar value: :reviewal_progress
  # end

  column :controlling_user, default: true, includes: [payment_order: {bank_payment_request: :controlling_user}] do
    user value: -> (context) { context[:record].payment_order.bank_payment_request.controlling_user }
  end

  column :controlling_level, default: true, includes: [payment_order: {bank_payment_request: :controlling_level}] do
    text value: "{{record.payment_order.bank_payment_request.controlling_level.name}}"
  end

  column :payment_mode do
    text value: :payment_mode
  end

  counter -> (user, collection) do
    # 90 :open,  :retracted
    # 91 :awaiting_approval
    # 92 :submitted, :processing, :unapprove
    # 93 :approved, :pending, :creation_in_progress, :auto_approved
    # :rejected,
    # :credited

    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :with_status_id
    counts = collection.group(:payment_status_id).count
    counter.add nil, "All", counts.values.reduce(0, :+)
    # # Open / Retracted
    # counter.add 90, 'Open', (counts[BankPaymentRequestStatus.id_for(:open)] + counts[BankPaymentRequestStatus.id_for(:retracted)])
    #
    # # Awaiting Approval
    # if user.has_permission?(awaiting_approval_roles)
    #   counter.add 91, 'Awaiting Approval',
    #               collection.where(status_id: BankPaymentRequestStatus.id_for(:processing), controlling_user_id: user.id).count
    # end
    #
    # counter.add 92, "Processing", (
    # (counts[BankPaymentRequestStatus.id_for(:processing)] || 0) +
    #     (counts[BankPaymentRequestStatus.id_for(:submitted)] || 0) +
    #     (counts[BankPaymentRequestStatus.id_for(:unapprove)] || 0)
    # )
    #
    # # Approved / Auto Approved
    # counter.add 93, 'Approved', (
    # (counts[BankPaymentRequestStatus.id_for(:approved)] || 0) +
    #     (counts[BankPaymentRequestStatus.id_for(:auto_approved)] || 0) +
    #     (counts[BankPaymentRequestStatus.id_for(:creation_in_progress)] || 0) +
    #     (counts[BankPaymentRequestStatus.id_for(:pending)] || 0)
    # )
    #
    # [:rejected, :credited].each do |status|
    #   counter.add BankPaymentRequestStatus.id_for(status), status.to_s.titleize, counts[BankPaymentRequestStatus.id_for(status)]
    # end

    counter
  end

  def self.format_status(context)
    case context[:record].status&.name&.to_s&.to_sym
    when :failed, :cancelled
      format = 'danger'
    when :completed
      format = 'success'
    when :scheduled, :possible_failure, :pending_credit
      # Todo show awaiting approvals
      # if context[:record].controlling_user_id == context[:user].id
        format = 'warning'
      # else
      #   format = 'info'
      # end
    when :pending, :in_progress, :processing, :pending_approval, :pending_retry, :initiated
      format = 'info'
    else
      format = 'danger'
    end
    format
  end

  # def self.data_provider(user, record, exposure)
  #   case record.parent_type
  #   when 'Invoice'
  #     Docs::P2P::Invoices::Index
  #   when 'PurchaseOrder'
  #     Docs::P2P::PurchaseOrders::Index
  #   when 'BeneficiaryPayment'
  #     Docs::P2P::BeneficiaryPayment::Index
  #   when 'BbpsBill'
  #     Docs::UtilityBills::Bills::Index
  #   else
  #     self
  #   end
  # end

end