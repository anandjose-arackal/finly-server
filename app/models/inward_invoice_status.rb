# == Schema Information
#
# Table name: inward_invoice_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class InwardInvoiceStatus < NonTenantedApplicationRecord
  include Seedable

  GROUP_OPEN = 90
  GROUP_AWAITING_APPROVAL = 91
  GROUP_PENDING_PAYMENT = 92

  def self.values
    [:unpaid, :partially_paid, :paid, :open, :retracted, :processing, :approved, :rejected, :auto_approved, :closed, :pending, :initiated, :voided]
  end

  def unpaid?
    self.id == InwardInvoiceStatus.id_for(:unpaid)
  end

  def partially_paid?
    self.id == InwardInvoiceStatus.id_for(:partially_paid)
  end

  def paid?
    self.id == InwardInvoiceStatus.id_for(:paid)
  end

  def open?
    self.id == InwardInvoiceStatus.id_for(:open)
  end

  def processing?
    self.id == InwardInvoiceStatus.id_for(:processing)
  end

  def approved?
    self.id == InwardInvoiceStatus.id_for(:approved)
  end

  def rejected?
    self.id == InwardInvoiceStatus.id_for(:rejected)
  end

  def auto_approved?
    self.id == InwardInvoiceStatus.id_for(:auto_approved)
  end

  def closed?
    self.id == InwardInvoiceStatus.id_for(:closed)
  end

  def retracted?
    self.id == InwardInvoiceStatus.id_for(:retracted)
  end

  def pending?
    self.id == InwardInvoiceStatus.id_for(:pending)
  end

  def initiated?
    self.id == InwardInvoiceStatus.id_for(:initiated)
  end


  # this will encapsulate all IDs of an invoice that come under the committed bucket of a budget
  def self.ids_for_committed_bucket
    [
        # InwardInvoiceStatus.id_for(:open),
        # InwardInvoiceStatus.id_for(:rejected),
        # InwardInvoiceStatus.id_for(:retracted),
        InwardInvoiceStatus.id_for(:approved),
        InwardInvoiceStatus.id_for(:auto_approved),
        # InwardInvoiceStatus.id_for(:processing)
    ]
  end

  def self.ids_for_pending_payment_bucket
    [
        InwardInvoiceStatus.id_for(:unpaid),
        InwardInvoiceStatus.id_for(:partially_paid),
        InwardInvoiceStatus.id_for(:initiated),
        # InwardInvoiceStatus.id_for(:paid)
    ]
  end

  # the below is the bucket from which paid amount will be considered
  def self.ids_for_paid_amount_consideration
    [
        # InwardInvoiceStatus.id_for(:open),
        # InwardInvoiceStatus.id_for(:retracted),
        # InwardInvoiceStatus.id_for(:processing),
        InwardInvoiceStatus.id_for(:approved),
        InwardInvoiceStatus.id_for(:auto_approved),
        InwardInvoiceStatus.id_for(:unpaid),
        InwardInvoiceStatus.id_for(:partially_paid),
        InwardInvoiceStatus.id_for(:initiated),
        InwardInvoiceStatus.id_for(:paid)
    ]
  end

  # THIS INCLUDES THE PAID BUCKET
  def self.ids_for_payment_processing_bucket
    [
        InwardInvoiceStatus.id_for(:initiated),
        InwardInvoiceStatus.id_for(:partially_paid),
        InwardInvoiceStatus.id_for(:paid)
    ]
  end

  # Status IDs for budget trails which are not calculated into budgets
  def self.status_ids_for_unbudgetables
    [
        InwardInvoiceStatus.id_for(:open),
        InwardInvoiceStatus.id_for(:rejected),
        InwardInvoiceStatus.id_for(:retracted)
    ]
  end

  def voided?
    self.id == InwardInvoiceStatus.id_for(:voided)
  end

  def self.status_ids_for_owner
    [
        PurchaseOrderStatus.id_for(:open),
        PurchaseOrderStatus.id_for(:rejected),
        PurchaseOrderStatus.id_for(:retracted)
    ]
  end

  def as_json(options={})
    {
        id: id,
        name: name
    }
  end

end
