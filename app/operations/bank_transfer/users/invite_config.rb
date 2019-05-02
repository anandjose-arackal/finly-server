class BankTransfer::Users::InviteConfig < BankTransfer::Users::Base

  attr_accessor :policies, :result, :role_groups, :feature_subscription

  def authorized_user_types
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.result = Policy::VendorPayments::Index.(user, params)
    self.feature_subscription = user.company.feature_subscription
  end

  def validate
    unless result.success?
      add_message :error, 'No policy found'
    end
  end

  def process
    self.admin_policies = result.admin_policies
    group_roles
  end

  def success
    params[:admin_policies] = self.admin_policies
    BankTransfer::Users::InviteConfig::InviteConfigPresenter.new(user, params, messages)
  end

  class BankTransfer::Users::InviteConfig::InviteConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :admin_policies

    def init
      self.admin_policies = params[:admin_policies]
    end
  end

  def group_roles
    if feature_subscription.procurement
      {
        name: 'Purchase Order',
        roles: [
          {
            key: 'purchase_order_initiator',
            label: 'Purchase Order Initiator'
          },
          {
            key: 'purchase_order_reviewer',
            label: 'Purchase Order Reviewer'
          },
        ]
      }
    end
    if feature_subscription.yes_bank_account
    end
    if feature_subscription.vendor_empanelment_workflow
    end
    if feature_subscription.purchase_requisition_system
    end
    if feature_subscription.budgeting_system
    end
    if feature_subscription.invoicing_system
    end
  end

end