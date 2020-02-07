class PaymentAgreements::Index < PaymentAgreements::Base
  attr_accessor :payment_agreements
  def init

  end

  def validate

  end

  def process
    if user.vendor_payments_admin? || user.is_agreement_invoice_initiator? || user.is_agreement_invoice_reviewer? || user.is_agreement_invoice_auditor?
      admin_restricted_status_ids = [PaymentAgreementStatus.id_for(:draft)]
      self.payment_agreements = ::PaymentAgreement.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids})
      self.payment_agreements = user.payment_agreements.or(payment_agreements)
      if self.payment_agreements.present?
        self.payment_agreements = self.payment_agreements.exclude_revision
      end
      return
    end

    unless user.policy_user_roles.pluck(:user_role_id).uniq.blank?
      self.payment_agreements = ::PaymentAgreement.associated_items(user, ::PaymentAgreement.roles) || PaymentAgreement.none
    else
      self.payment_agreements = user.payment_agreements
    end
  end

  def success
    params[:payment_agreements] = self.payment_agreements
    PaymentAgreements::Index::IndexPresenter.new(user, params, messages)
  end

  class PaymentAgreements::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_agreements, :paginated_payment_agreements, :count

    has_scope :filter_title
    has_scope :filter_vendor_id
    has_scope :filter_policy_id
    has_scope :filter_creation_date
    has_scope :filter_creator_id
    has_scope :created_by_name
    has_scope :filter_status_id
    has_scope :filter_status # TODO: remove it
    has_scope :filter_invoice_due_date, using: [:from, :to], type: :hash
    has_scope :filter_by_date_range, using: [:from, :to], type: :hash
    has_scope :filter_by_status_id
    has_scope :filter_awaiting_approval
    has_scope :search_by_email
    has_scope :filter_agreement_type
    has_scope :filter_invoice_number


    def init
      self.payment_agreements = params[:payment_agreements]
      self.payment_agreements = apply_scopes(payment_agreements, params)
      self.paginated_payment_agreements = payment_agreements.order(created_at: :desc).paginate(page: params[:page], per_page: params[:per_page]) rescue ::PaymentAgreement.none
      self.count = payment_agreements&.count
    end

  end
end