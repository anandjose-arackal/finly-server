class Admin::Implementations::Master::PolicyUserRole::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'policy_user_role.export'
  has_scope :with_id

  headers({
              "Vendor Payments" => {:policy_name => 'Policy Name',
                                    :user_id => 'User Email / Mobile / Employee Id',
                                    :purchase_request_initiator => 'Purchase Request Initiator',
                                    :purchase_request_reviewer => 'Purchase Request Reviewer',
                                    :purchase_request_auditor => 'Purchase Request Auditor',
                                    :purchase_order_initiator => 'Purchase Order Intiator',
                                    :purchase_order_reviewer => 'Purchase Order Reviwer',
                                    :purchase_order_auditor => 'Purchase Order Auditor',
                                    :goods_receiver => 'Goods Receiver',
                                    :po_invoice_initiator => "PO Invoice Initiator",
                                    :po_invoice_reviewer => "PO Invoice Reviewer",
                                    :po_invoice_auditor => "PO Invoice Auditor",
                                    :non_po_invoice_initiator => "Non PO Invoice Initiator",
                                    :non_po_invoice_reviewer => "Non PO Invoice Reviewer",
                                    :non_po_invoice_auditor => "Non PO INvoice Auditor",
                                    :bank_payment_request_initiator => 'Bank Payment Request Initiator',
                                    :bank_payment_request_reviewer => 'Bank Payment Request Reviewer',
                                    :bank_payment_request_creditor => 'Bank Payment Request Creditor',
                                    :bank_payment_request_auditor => 'Bank Payment Request Auditor',
                                    :item_master_manager => 'Item Master Manager',
                                    :inventory_manager => 'Inventory Manager',
                                    :vendor_creator => 'Vendor Creator',
                                    :vendor_reviewer => 'Vendor Reviewer',
                                    :vendor_auditor => 'Vendor Auditor',
                                    :vendor_manager => 'Vendor Manager',
                                    :payment_agreement_initiator => "Payment Agreement Initiator",
                                    :payment_agreement_reviewer => "Payment Agreement Reviewer",
                                    :payment_agreement_auditor => "Payment Agreement Auditor",
                                    :budget_manager => 'Budget Manager',
                                    :utility_bill_master_initiator => 'Utility Bill Master Initiator',
                                    :utility_bill_master_reviewer => 'Utility Bill Master Reviewer',
                                    :utility_bill_initiator => 'Utility Bill Initiator',
                                    :utility_bill_reviewer => 'Utility Bill Reviewer',
                                    :credit_note_initiator => 'Credit Note Initiator',
                                    :credit_note_reviewer => 'Credit Note Reviewer',
                                    :credit_note_auditor => 'Credit Note Auditor',
                                    :agreement_invoice_initiator => 'Agreement Invoice Initiator',
                                    :agreement_invoice_reviewer => 'Agreement Invoice Reviewer',
                                    :agreement_invoice_auditor => 'Agreement Invoice Auditor'
              },
              "Expense Management" => {
                  :policy_name => 'Policy Name',
                  :user_id => 'User Email / Mobile',
                  :initiator => "Initiator",
                  :manager => "Manager",
                  :finance_manager => "Finance Manager"
              }
          })

  def valid_request

  end

  def input

  end



  def user_email_mobile(user)
    identifier = user&.email
    if identifier.blank?
      identifier = user&.mobile_number
    end
    identifier
  end

  def destroy(lrm)
    ''
  end

  def post_process
  end

  def contents
    contents = {}

    if params[:with_id] == 'all'
      params[:with_id] = company.policies.pluck(:id)
    end
    headers.keys.each do |key|

      total_count = 0
      contents[key] = []
      if key == 'Vendor Payments'
        contents[key] = get_policy_user_roles
      elsif key == 'Expense Management'
        contents[key] = get_policy_user_mapping
      end
    end
    contents
  end

  def export(headers, contents)
    file = Tempfile.new(['policy_user_role_result', '.xlsx'])
    workbook  = ::WriteXLSX.new(file)
    contents.each  do |name, sheet|
      worksheet = workbook.add_worksheet(name)
      self.headers[name].values.each_with_index do |item, index|
        worksheet.write( 0, index, item )
      end
      sheet.each_with_index do |items, row|
        items.each_with_index do |item, column|
          worksheet.write(1 + row, column, item)
        end
      end
    end
    workbook.close
    file.rewind
    self.implementation_request.result_file = file
    self.implementation_request.save
    progress_update(:completed)
  end

  def get_policy_user_roles
    policies = apply_scopes(company.policies)
    result =[]
    user_role_names = headers["Vendor Payments"].keys - [:user_id, :policy_name]
    policies.includes(:policy_user_roles).each do |policy|
      policy.policy_user_roles.group_by(&:user_id).each do |user_id, purs|
        user_role_ids =purs.map(&:user_role_id).uniq
        row=[]
        row << policy.name
        row << user_email_mobile(purs.first.user)
        user_role_names.map{ |user_role_name| row << (user_role_ids.include?(UserRole.id_for(user_role_name)) ? "Y" : "") }
        result << row
      end
    end
    result
  end

  def get_policy_user_mapping
    policies = apply_scopes(company.policies)
    user_role_names = headers["Expense Management"].keys - [:user_id, :policy_name]
    user_role_mapping = UserRoleMapping.select("user_role_id, user_id").where(purpose_id: Purpose.id_for(:expense_management),user_id: company.users&.pluck(:id)).to_a&.group_by(&:user_id)
    user_based_role_ids = {}
    user_role_mapping.map{|mapping| user_based_role_ids.merge!({mapping[0] => mapping[1].map(&:user_role_id).uniq})}
    result =[]
    user_role_names = headers["Expense Management"].keys - [:user_id, :policy_name]
    policies.includes(:users).each do |policy|
      policy.users.each do |user|
        next unless user&.user_panel_subscription&.expense_management
        row=[]
        row << policy.name
        row << user_email_mobile(user)
        user.policy_user_roles.where(purpose_id: 1)
        user_role_names.map{ |user_role_name| row << (user_based_role_ids[user.id].include?(UserRole.id_for(user_role_name)) ? "Y" : "") }
        result << row
      end
    end
    result
  end


end
