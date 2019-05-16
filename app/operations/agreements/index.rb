class PaymentAgreements::Index < PaymentAgreements::Base
  attr_accessor :payment_agreements, :policies
  def init

  end

  def validate

  end

  def process
    if user.vendor_payments_admin?
      admin_restricted_status_ids = [PaymentAgreementStatus.id_for(:draft)]
      self.payment_agreements = ::PaymentAgreement.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids})
      self.payment_agreements = user.payment_agreements.or(payment_agreements)
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

    def init
      self.payment_agreements = params[:payment_agreements]
      self.paginated_payment_agreements = payment_agreements.order(created_at: :desc).paginate(page: params[:page], per_page: 30) rescue ::PaymentAgreement.none
      self.count = payment_agreements&.count
    end

  end
end