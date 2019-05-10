class BankTransfer::Users::Policies < BankTransfer::Users::Base
  attr_accessor :policies, :selected_user

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.selected_user = BankTransfer::Users::Show.(user, params).selected_user rescue nil
  end

  def validate
    unless self.selected_user.present?
      add_message :error, "Selected User not Found"
    end
  end

  def process
    self.policies = Policy::VendorPayments::Index.(self.selected_user, params).policies rescue Policy.none
    # self.policy_user_roles = PolicyUserRole.where(policy_id: policies.pluck(:id), user_id: selected_user.id).includes(:policy, :user_role)
  end

  def success
    params[:policies] = self.policies
    params[:selected_user] = self.selected_user
    BankTransfer::Users::Policies::PoliciesPresenter.new(user, params, messages)
  end

  class BankTransfer::Users::Policies::PoliciesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :policies, :selected_user

    def init
      self.policies = params[:policies]
      self.selected_user = params[:selected_user]
      self.policies = self.policies.includes(policy_user_roles: [:user_role]).where(policy_user_roles: {user_id: user.id})
    end
  end
end