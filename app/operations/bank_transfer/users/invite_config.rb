class BankTransfer::Users::InviteConfig < BankTransfer::Users::Base

  attr_accessor :admin_policies, :result, :role_groups, :feature_subscription

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
    self.role_groups = group_roles
  end

  def success
    params[:admin_policies] = self.admin_policies
    params[:role_groups] = self.role_groups
    BankTransfer::Users::InviteConfig::InviteConfigPresenter.new(user, params, messages)
  end

  class BankTransfer::Users::InviteConfig::InviteConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :admin_policies, :role_groups

    def init
      self.admin_policies = params[:admin_policies]
      self.role_groups = params[:role_groups]
    end
  end

  def group_roles
    data =  []
    if feature_subscription.procurement
      data << {
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
          {
            key: 'purchase_order_auditor',
            label: 'Purchase Order Auditor'
          },
          {
            key: 'goods_receiver',
            label: 'Goods Receiver'
          }
        ]
      }
    end
    if feature_subscription.yes_bank_account
      data << {
        name: 'Payment Ticket',
        roles: [
          {
            key: 'bank_payment_request_initiator',
            label: 'Payment Ticket Initiator'
          },
          {
            key: 'bank_payment_request_reviewer',
            label: 'Payment Ticket Reviewer'
          },
          {
            key: 'bank_payment_request_creditor',
            label: 'Payment Ticket Creditor'
          },
          {
            key: 'bank_payment_request_auditor',
            label: 'Payment Ticket Auditor'
          },
          {
            key: 'inventory_manager',
            label: 'Inventory Manager'
          },
          {
            key: 'item_master_manager',
            label: 'Item Master Manager'
          }
        ]
      }
    end
    if feature_subscription.vendor_empanelment_workflow
      data << {
        name: 'Vendor',
        roles: [
          {
            key: 'vendor_creator',
            label: 'Vendor Creator'
          },
          {
            key: 'vendor_reviewer',
            label: 'Vendor Reviewer'
          },
          {
            key: 'vendor_manager',
            label: 'Vendor Manager'
          }
        ]
      }
    end
    if feature_subscription.purchase_requisition_system
      data << {
        name: 'Purchase Requisition',
        roles: [
          {
            key: 'purchase_request_initiator',
            label: 'Purchase Request Initiator'
          },
          {
            key: 'purchase_request_reviewer',
            label: 'Purchase Request Reviewer'
          },
          {
            key: 'purchase_request_auditor',
            label: 'Purchase Request Auditor'
          }
        ]
      }
    end
    if feature_subscription.budgeting_system
      data << {
        name: 'Budget',
        roles: [
          {
            key: 'budget_manager',
            label: 'Budget Manager'
          }
        ]
      }
    end
    if feature_subscription.invoicing_system
      data << {
        name: 'Invoice',
        roles: [
          {
            key: 'invoice_initiator',
            label: 'Invoice Initiator'
          },
          {
            key: 'invoice_reviewer',
            label: 'Invoice Reviewer'
          }
        ]
      }
    end
    data
  end

end