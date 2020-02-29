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

    attr_accessor :admin_policies, :role_groups, :company, :user

    def init
      self.admin_policies = params[:admin_policies]
      self.role_groups = params[:role_groups]
      self.company  = user.company
      self.user = user
    end
  end

  def group_roles
    data =  []
    data << {
        name: "Administrator",
        roles: [
            {
                key: 'admin',
                label: 'Admin'
            }
        ]
    }
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
          }
        ]
      }

     data << {
        name: 'Inventory',
        roles: [
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
          },
          {
            key: 'vendor_auditor',
            label: 'Vendor Auditor'
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
      # data << {
      #   name: 'Invoice',
      #   roles: [
      #     {
      #       key: 'invoice_initiator',
      #       label: 'Invoice Initiator'
      #     },
      #     {
      #       key: 'invoice_reviewer',
      #       label: 'Invoice Reviewer'
      #     }
      #   ]
      # }
      data << {
        name: 'PoInvoice',
        roles: [
          {
            key: 'po_invoice_initiator',
            label: 'PO Invoice Initiator'
          },
          {
            key: 'po_invoice_reviewer',
            label: 'PO Invoice Reviewer'
          },
          {
            key: 'po_invoice_auditor',
            label: 'PO Invoice Auditor'
          }
        ]
      }

      data << {
        name: 'Non PO Invoice',
        roles: [
          {
            key: 'non_po_invoice_initiator',
            label: 'Non PO Invoice Initiator'
          },
          {
            key: 'non_po_invoice_reviewer',
            label: 'Non PO Invoice Reviewer'
          },
          {
            key: 'non_po_invoice_auditor',
            label: 'Non PO Invoice Auditor'
          }
        ]
      }

      data << {
          name: 'Agreement Invoice',
          roles: [
              {
                  key: 'agreement_invoice_initiator',
                  label: 'Agreement Invoice Initiator'
              },
              {
                  key: 'agreement_invoice_reviewer',
                  label: 'Agreement Invoice Reviewer'
              },
              {
                  key: 'agreement_invoice_auditor',
                  label: 'Agreement Invoice Auditor'
              }
          ]
      }
    end
    if feature_subscription.agreement_based_payment_system
      data << {
        name: 'Payment Agreement',
        roles: [
          {
            key: 'payment_agreement_initiator',
            label: 'Payment Agreement Initiator'
          },
          {
            key: 'payment_agreement_reviewer',
            label: 'Payment Agreement Reviewer'
          },
          {
            key: 'payment_agreement_auditor',
            label: 'Payment Agreement Auditor'
          }
        ]
      }
    end
    data
  end

end