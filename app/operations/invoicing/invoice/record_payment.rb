class Invoicing::Invoice::RecordPayment < Invoicing::Invoice::Base

  attr_accessor :invoice, :amount,
                :action_name, :action_id, :customer_account_transaction,
                :customer_account, :payment_date, :date, :note

  def pre_validate
    action_names = OutwardInvoiceTrailAction.all.pluck(:name)
    unless action_names.include?(params[:action_id])
      add_message :error, 'Invalid Configuration Provided'
    end
  end

  def init
    id = params[:id] || params[:outward_invoice_id]
    self.invoice = user.company.outward_invoices.find_by(id: id)

    self.amount = params[:amount].to_f
    self.action_name = params[:action_id]
    self.action_id = OutwardInvoiceTrailAction.id_for(params[:action])
    self.payment_date = Date.parse(params[:date]) rescue nil
    self.note = params[:note]


    case action_name
      when 'credit_customer_account'
        if invoice.is_a?(OutwardInvoice)
          self.customer_account = invoice.customer.customer_account
        end
      when 'debit_customer_account'
        if invoice.is_a?(OutwardInvoice)
          self.customer_account = invoice.customer.customer_account
        end
    end


  end

  def validate
    if self.invoice.blank?
      add_message :error, "Invoice not found"
      return
    end

    if self.amount.to_f < 0
      add_message :error, "Amount cannot be negative"
      return
    end

    case action_name
      when 'credit_customer_account'
        if amount > invoice.balance_due.value
          add_message :error, 'Cannot credit amount greater than balance due'
        end

        if amount > customer_account.balance.value
          add_message :error, 'Cannot credit amount greater than customer account balance'
        end
      when 'credit_outside'
        if amount > invoice.balance_due.value
          add_message :error, 'Cannot credit amount greater than balance due'
        end
      when 'debit_customer_account'
        if amount > get_amount_transferred_by_va
          add_message :error, 'Cannot retract amount greater than amount transferred through virtual account or customer account'
          return
        end
      when 'debit_outside'
        if amount > get_amount_transferred_outside_finly
          add_message :error, 'Cannot subtract amount greater amount transferred outside finly'
        end

    end

  end

  def process

    case action_name
      when 'credit_customer_account'
        if self.amount < invoice.balance_due.value
          new_paid_amount = invoice.paid_amount&.value + self.amount
          new_balance_due = invoice.balance_due&.value - self.amount
          invoice_status_id = OutwardInvoiceStatus.id_for(:partially_paid)
        else
          new_paid_amount = invoice.net_amount&.value + invoice.roundoff_amount
          new_balance_due = 0
          invoice_status_id = OutwardInvoiceStatus.id_for(:closed)
        end
        self.invoice.assign_attributes({
                                invoice_status_id: invoice_status_id,
                                paid_amount_attributes: {
                                    id: invoice.paid_amount.id,
                                    value: new_paid_amount
                                },
                                balance_due_attributes: {
                                    id: invoice.balance_due.id,
                                    value: new_balance_due
                                }
                            })
        # If invoice is valid then deduct amount from Customer Account
        if invoice.valid?
          op = AccountManager::Collect::CustomerAccount::Transfer.(user, {
              type: 'customer_account_to_invoice',
              amount: self.amount,
              invoice: self.invoice
          })

          if op.failure?
            # if deducting money from customer account fails, do not proceed saving the invoice or the trail there after
            add_message :error, 'Could not proceed with operation'
            return
          else
            # If deducting money from customer account is successful, save invoice (which is already validated)
            invoice.save

            # creat trail from invoice
            self.invoice.invoice_trails.create({
                                                   action_id: OutwardInvoiceTrailAction.id_for(self.action_name),
                                                   associated_transaction: op.customer_account_transaction,
                                                   amount_attributes: {
                                                       value: self.amount,
                                                       currency_id: 1 # todo change currncy
                                                   },
                                                   user: user,
                                                   date: self.date,
                                                   note: self.note
                                               })
            add_message :success, 'Successfully added payment to invoice from Customer account'

          end

        else
          add_message :error, self.invoice.errors.full_messages
        end
        # credit_customer_account ends

      when 'credit_outside'
        if self.amount < invoice.balance_due.value
          new_paid_amount = invoice.paid_amount&.value + self.amount
          new_balance_due = invoice.balance_due&.value - self.amount
          invoice_status_id = OutwardInvoiceStatus.id_for(:partially_paid)
        else
          new_paid_amount = invoice.net_amount&.value + invoice.roundoff_amount
          new_balance_due = 0
          invoice_status_id = OutwardInvoiceStatus.id_for(:closed)
        end
        self.invoice.assign_attributes({
                                invoice_status_id: invoice_status_id,
                                paid_amount_attributes: {
                                    id: invoice.paid_amount.id,
                                    value: new_paid_amount
                                },
                                balance_due_attributes: {
                                    id: invoice.balance_due.id,
                                    value: new_balance_due
                                }
                            })
        # If invoice is valid then deduct amount from Customer Account
        if invoice.valid?

          invoice.save

          # creat trail from invoice
          self.invoice.invoice_trails.create({
                                                 action_id: OutwardInvoiceTrailAction.id_for(self.action_name),
                                                 amount_attributes: {
                                                     value: self.amount,
                                                     currency_id: 1 # todo change currncy
                                                 },
                                                 user: user,
                                                 date: self.date,
                                                 note: self.note
                                             })
          add_message :success, 'Successfully added payment to invoice'

        else
          add_message :error, self.invoice.errors.full_messages
        end
        # credit_customer_account ends
      when 'debit_customer_account'
        # 1. get amount which is added from virtual account

        # if self.amount < invoice.balance_due.value

        #todo check calculation again
        new_paid_amount = invoice.paid_amount&.value - self.amount
        new_balance_due = invoice.balance_due&.value + self.amount
        invoice_status_id = OutwardInvoiceStatus.id_for(:partially_paid)
        # else
        #   new_paid_amount = invoice.net_amount&.value + invoice.roundoff_amount
        #   new_balance_due = 0
        #   invoice_status_id = OutwardInvoiceStatus.id_for(:closed)
        # end


        # 2. assign attributes to invoice
        self.invoice.assign_attributes({
                                invoice_status_id: invoice_status_id,
                                paid_amount_attributes: {
                                    id: invoice.paid_amount.id,
                                    value: new_paid_amount
                                },
                                balance_due_attributes: {
                                    id: invoice.balance_due.id,
                                    value: new_balance_due
                                }
                            })
        # 3. create customer account transaction

        # If invoice is valid then deduct amount from Customer Account
        if invoice.valid?
          op = AccountManager::Collect::CustomerAccount::Transfer.(user, {
              type: 'invoice_to_customer_account',
              amount: self.amount,
              invoice: self.invoice
          })

          if op.failure?
            # if deducting money from customer account fails, do not proceed saving the invoice or the trail there after
            add_message :error, 'Could not proceed with operation'
            return
          else
            # If deducting money from customer account is successful, save invoice (which is already validated)
            invoice.save
            # creat trail from invoice
            self.invoice.invoice_trails.create({
                                                   action_id: OutwardInvoiceTrailAction.id_for(self.action_name),
                                                   associated_transaction: op.customer_account_transaction,
                                                   amount_attributes: {
                                                       value: self.amount,
                                                       currency_id: 1 # todo change currncy
                                                   },
                                                   user: user,
                                                   date: self.date,
                                                   note: self.note
                                               })
            add_message :success, 'Successfully retracted money from invoice to Customer account'
          end
        else
          add_message :error, self.invoice.errors.full_messages
        end

        # 4. save invoice
        # 5. create trail
      when 'debit_outside'
        new_paid_amount = invoice.paid_amount&.value - self.amount
        new_balance_due = invoice.balance_due&.value + self.amount
        invoice_status_id = OutwardInvoiceStatus.id_for(:partially_paid)
        self.invoice.assign_attributes({
                                invoice_status_id: invoice_status_id,
                                paid_amount_attributes: {
                                    id: invoice.paid_amount.id,
                                    value: new_paid_amount
                                },
                                balance_due_attributes: {
                                    id: invoice.balance_due.id,
                                    value: new_balance_due
                                }
                            })
        # If invoice is valid then deduct amount from Customer Account
        if invoice.valid?

          invoice.save

          # creat trail from invoice
          self.invoice.invoice_trails.create({
                                                 action_id: OutwardInvoiceTrailAction.id_for(self.action_name),
                                                 amount_attributes: {
                                                     value: self.amount,
                                                     currency_id: 1 # todo change currncy
                                                 },
                                                 user: user,
                                                 date: self.date,
                                                 note: self.note
                                             })
          add_message :success, 'Successfully added payment to invoice'

        else
          add_message :error, self.invoice.errors.full_messages
        end
    end
  end

  def post_process
    # add_message :success, "Invoice working"
  end


  private

  def get_amount_transferred_by_va
    trails = self.invoice.invoice_trails
    amount = 0

    for trail in trails
      credit_action_ids = [OutwardInvoiceTrailAction.id_for('credit_virtual_account'), OutwardInvoiceTrailAction.id_for('credit_customer_account')]
      debit_action_ids = [OutwardInvoiceTrailAction.id_for('debit_customer_account')]
      if credit_action_ids.include?(trail.action.id)
        amount += trail.amount.value
      elsif debit_action_ids.include?(trail.action.id)
        amount -= trail.amount.value
      end
    end


    amount

  end

  def get_amount_transferred_outside_finly
    trails = self.invoice.invoice_trails
    amount = 0

    for trail in trails
      credit_action_ids = [OutwardInvoiceTrailAction.id_for('credit_outside')]
      debit_action_ids = [OutwardInvoiceTrailAction.id_for('debit_outside')]
      if credit_action_ids.include?(trail.action.id)
        amount += trail.amount.value
      elsif debit_action_ids.include?(trail.action.id)
        amount -= trail.amount.value
      end
    end

    amount
  end


end