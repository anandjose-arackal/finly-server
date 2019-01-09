# this operation shows all the details about this user including the bank transfers done by him / her
# from Finly Vendor Credits or from the company credits

class BankTransfer::Users::Show < BankTransfer::Users::Base

  attr_accessor :selected_user, :role_id

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    self.role_id = params[:role_id]
    if role_id.blank? && params[:view].present?
      self.role_id = UserRole::VALUES[params[:view].to_sym]
    end
  end

  def validate
    unless role_id.present?
      add_message :error, "User role not defined"
    end
  end

  def process
    case role_id
    when UserRole.id_for(:admin)
      team = BankTransfer::Users::Index.(user, params).users rescue []
      id = params[:id] || params[:user_id]
      self.selected_user = team.find_by(id: id)
    else
      self.selected_user = user
    end
  end

  def success
    params[:selected_user] = selected_user
    BankTransfer::Users::Show::UserPresenter.new(user, params, messages)
  end

  class BankTransfer::Users::Show::UserPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :selected_user, :user_panel_subscription, :actions,
                  :mapping, :policy, :roles, :managers, :finance_managers,
                  :policies

    def init
      self.selected_user = params[:selected_user]
      self.user_panel_subscription = selected_user.user_panel_subscription
      self.actions = load_actions
      # todo - temporary, will be updated to all policies later - as of now only the default company policy
      self.policy = selected_user.company.policies.default.first
      policy_ids = selected_user.policy_user_mappings.non_deleted.pluck(:policy_id)
      self.policies = self.selected_user.company.policies.with_id(policy_ids)
      self.mapping = retrieve_mappings
      self.roles = {
          admin: selected_user.vendor_payment_admin?,
          finance_manager: selected_user.vendor_payment_finance?,
          manager: selected_user.vendor_payment_manager?,
          initiator: selected_user.vendor_payment_initiator?,
          auditor: selected_user.auditor?
      }
      self.managers = selected_user.company.users.only_vendor_payment_reviewers
      self.finance_managers = selected_user.company.users.only_vendor_payment_creditors
    end

    def load_actions
      actions = {}
      # adding actions for updating the panel subscriptions for the selected user
      if user.company_admin?
        actions[:update_subscriptions] = Rails.application.routes.url_helpers.user_path(id: self.selected_user.id)
      end
      credit_actions = {initiating_accounts: [], receiving_accounts: []}
      debit_actions = {receiving_accounts: [], initiating_accounts: []}
      action = {type: :wallet, id: user.bank_wallet.id, name: "#{user.name} Finly Credits", active: true}
      credit_actions[:initiating_accounts] << action
      debit_actions[:initiating_accounts] << action
      action = {type: :wallet, id: selected_user.bank_wallet.id, name: "#{selected_user} Finly Credits", active: true}
      credit_actions[:receiving_accounts] << action
      debit_actions[:receiving_accounts] << action
      actions[:transfer_options] = {
          credit_actions: credit_actions,
          debit_actions: debit_actions,
          credit: true,
          debit: true
      }
      actions
    end

    def retrieve_mappings
      mapping = []
      self.policies.each do |policy|
        mapping << Policy::Mappings::Show.(user, user: selected_user, policy: policy).map
      end
      mapping
    end
  end

end