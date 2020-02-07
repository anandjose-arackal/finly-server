class PaymentAgreements::AllUpcomingInvoices < PaymentAgreements::Base
  attr_accessor :invoices, :payment_agreement, :beneficiary_payments, :security_deposits, :general_invoices, :rental_invoices, :policies, :invoices

  def init
  end

  def validate

  end

  def process
    case params[:agreement_item_type]
    when 'general_invoice'
      self.invoices = general_invoices
    when 'rental_invoice'
      self.invoices = rental_invoices
    else
      add_message :error, "Invalid upcoming invoice type."
      return
    end

    initiating_user = self.payment_agreement.present? ? payment_agreement.creator : user
    self.policies = Policy::VendorPayments::Index.(initiating_user, params).policies
  end

  def success
    params[:invoices] = self.invoices
    params[:policies] = self.policies
    PaymentAgreements::AllUpcomingInvoices::AllUpcomingInvoicesPresenter.new(user, params, messages)
  end

  class PaymentAgreements::AllUpcomingInvoices::AllUpcomingInvoicesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoices, :general_invoices, :rental_invoices, :policies, :paginated_general_invoices, :paginated_rental_invoices

    has_scope :filter_policy_id
    has_scope :filter_vendor_id
    has_scope :filter_due_date
    has_scope :filter_creation_date
    has_scope :filter_from_date
    has_scope :filter_to_date
    has_scope :filter_upcoming_invoice_date, using: [:from, :to], type: :hash

    def init
      # self.general_invoices = params[:general_invoices]
      # if self.general_invoices.present?
      #   self.general_invoices = apply_scopes(general_invoices, params)
      #   self.paginated_general_invoices = general_invoices.order(payment_agreement_upcoming_date: :desc).paginate(page: params[:page], per_page: params[:per_page])
      # end
      # self.rental_invoices = params[:rental_invoices]
      # if self.rental_invoices.present?
      #   self.rental_invoices = apply_scopes(rental_invoices, params)
      #   self.paginated_rental_invoices = self.rental_invoices.order(payment_agreement_upcoming_date: :desc).paginate(page: params[:page], per_page: params[:per_page])
      # end

      self.invoices = params[:invoices]
      self.invoices = apply_scopes(invoices, params)

      self.paginated_invoices = self.invoices.order(payment_agreement_upcoming_date: :desc).paginate(page: params[:page], per_page: params[:per_page])

      self.policies = params[:policies]
    end
  end

  def general_invoices
    one_time_gi_invoices = user.company.general_invoices.where(billing_type_id: BillingType.id_for(:one_time)).where("start_date <= ? AND end_date >= ? AND payment_agreement_upcoming_date <= ?", Date.today, Date.today, Date.today).where(is_payment_agreement_upcoming_invoice: true) rescue GeneralInvoice.none

    fixed_periodic_gi_invoices = user.company.fixed_periodic_general_invoices.where(billing_type_id: BillingType.id_for(:fixed_periodic), is_payment_agreement_upcoming_invoice: true).where("payment_agreement_upcoming_date <= ?", Date.today).where(fixed_periodic_template: true) rescue GeneralInvoice.none

    one_time_gi_invoices.or(fixed_periodic_gi_invoices)
  end

  def rental_invoices
    one_time_ri_invoices = user.company.rental_invoices.where(billing_type_id: BillingType.id_for(:one_time)).where("start_date <= ? AND end_date >= ? AND payment_agreement_upcoming_date <= ?", Date.today, Date.today, Date.today).where(is_payment_agreement_upcoming_invoice: true) rescue RentalInvoice.none

    fixed_periodic_ri_invoices = user.company.fixed_periodic_rental_invoices.where(billing_type_id: BillingType.id_for(:fixed_periodic), is_payment_agreement_upcoming_invoice: true).where("payment_agreement_upcoming_date <= ?", Date.today).where(fixed_periodic_template: true) rescue RentalInvoice.none

    one_time_ri_invoices.or(fixed_periodic_ri_invoices)
  end

end