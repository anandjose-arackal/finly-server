class Admin::Implementations::Master::PolicyUserRole::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'policy_user_role.import_template'

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
    []
  end

  def post_process
  end

  def export(headers, contents)
    file = Tempfile.new(['policy_user_roles', '.xlsx'])
    workbook  = ::WriteXLSX.new(file)
    headers.each do |key, value|
      worksheet = workbook.add_worksheet(key)

      value.values.each_with_index do |item, index|
        worksheet.write( 0, index, item )
      end

    end
    workbook.close
    file.rewind

    temp_file = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 1.day)
    temp_file.file.url
  end

end
