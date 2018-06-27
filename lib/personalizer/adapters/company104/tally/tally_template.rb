# 1 report = 1 voucher
# Only reimbursable expenses are considered
# Party A/c = Party account, which is picked up from a expense custom field
# Ledger = gl_code picked up from expense category
# Employee GL Code = GL Code picked up from user.gl_config[:name]
#
# Case 1: No TDS or GST
#   Journal:
#     Ledger debit ( Expense amount )
#     Employee GL Code Credit ( Expense Amount )
#
# Case 2: With TDS
#   Journal:
#     Party A/c Debit ( Expense Amount - TDS Amount )
#     Employee GL Code Credit ( Expense Amount - TDS Amount)
#   Purchase:
#     Ledger Debit ( Expense Amount )
#     Party A/c Credit ( Expense Amount - TDS Amount )
#     TDS Name Credit ( TDS Amount )
#
# Case 3: With GST
#   Journal:
#     Ledger Debit ( Expense Amount )
#     Employee GL Code Credit ( Expense Amount )
#   Purchase:
#     Ledger Debit ( Expense Amount )
#     Input IGST (#{GST Percentage}) Debit ( GST Amount )
#     Party A/c Credit ( Expense Amount )
#

class Personalizer::Adapters::Company104::Tally::TallyTemplate
  include ERB::Util

  def self.validate(expenses)
    expenses.reimbursable.each do |expense|
      if expense.user.gl_config&.dig(:name).blank?
        raise 'GL Config is not configured for the user'
      end
    end
  end

  # {
  #   request: {
  #     "#{report_id}": {
  #       "#{voucher_name -> purchase/journal}" : {
  #         name: #{Purchase/Journal},
  #         date: #{date},
  #         cost_center_name: #{cost center name}
  #         transactions : {
  #           ledger_name: #{ledger name},
  #           amount: #{amount value}
  #         }
  #       }
  #     }
  #   }
  # }
  def self.generate_request_for(expenses, configuration)
    request = {}
    expenses.reimbursable.each do |expense|
      if request[expense.report_id].blank?
        cost_center = expense.report.custom_fields.with_field_key('tally_cost_center')&.first&.value&.value
        request[expense.report_id] = {cost_center: cost_center}
      end


      date = ERB::Util.html_escape(configuration.date_for(expense))
      user = ERB::Util.html_escape(expense.user.gl_config[:name])

      has_gst = expense.has_gst?
      has_tds = expense.has_tds?

      ledger_name = ERB::Util.html_escape expense.category.gl_name
      expense_amount = expense.amount.INR
      party_account_name = expense.custom_fields.with_field_key('tally_party_name')&.first&.value&.value

      voucher_purchase = 'Purchase'
      voucher_journal = 'Journal'

      if request[expense.report_id][voucher_journal].blank?
        request[expense.report_id][voucher_journal] = {
            name: voucher_journal,
            date: date,
            transactions: {}
        }
      end

      if (has_tds or has_gst) and request[expense.report_id][voucher_purchase].blank?
        request[expense.report_id][voucher_purchase] = {
            name: voucher_purchase,
            date: date,
            transactions: {}
        }
        if party_account_name
          raise 'Party account name has not been defined'
        end
      end

      if has_tds
        #   Journal:
        #     Party A/c Debit ( Expense Amount - TDS Amount )
        #     Employee GL Code Credit ( Expense Amount - TDS Amount)
        #   Purchase:
        #     Ledger Debit ( Expense Amount )
        #     Party A/c Credit ( Expense Amount - TDS Amount )
        #     TDS Name Credit ( TDS Amount )
        tds_account_name = expense.tds_slab.name
        tds_amount = expense.tds_amount.INR
        reimbursable_amount = expense_amount - tds_amount

        # Purchase -> Ledger Debit (Expense Amount)
        update_voucher(request[expense.report_id][voucher_purchase], ledger_name, -expense_amount)
        # Purchase -> Party A/C Credit ( Expense Amount - TDS Amount )
        update_voucher(request[expense.report_id][voucher_purchase], party_account_name, reimbursable_amount)
        # Purchase -> TDS A/c Credit ( TDS Amount )
        update_voucher(request[expense.report_id][voucher_purchase], tds_account_name, tds_amount)

        # Journal -> Debit party account
        update_voucher(request[expense.report_id][voucher_journal], party_account_name, -reimbursable_amount)
        # Journal -> Add reimbursable amount to employee's account
        update_voucher(request[expense.report_id][voucher_journal], user, reimbursable_amount)
      elsif has_gst
        #   Journal:
        #     Ledger Debit ( Expense Amount )
        #     Employee GL Code Credit ( Expense Amount )
        #   Purchase:
        #     Ledger Debit ( Expense Amount )
        #     Input IGST (#{GST Percentage}) Debit ( GST Amount )
        #     Party A/c Credit ( Expense Amount )

        # Journal -> Ledger Debit ( Expense Amount )
        update_voucher(request[expense.report_id][voucher_journal], ledger_name, -expense_amount)
        # Journal -> Employee GL Code Credit ( Expense Amount )
        update_voucher(request[expense.report_id][voucher_journal], user, expense_amount)

        # Purchase -> Ledger Debit ( Expense Amount )
        update_voucher(request[expense.report_id][voucher_purchase], ledger_name, -expense_amount)
        # Purchase -> Party A/c Credit ( Expense Amount )
        update_voucher(request[expense.report_id][voucher_purchase], party_account_name, expense_amount)

        gst_amount = expense.gst_amount.INR
        gst_percentage = expense.gst_percentage
        if expense.gst_type.igst?
          gst_account_name = "Input IGST #{gst_percentage}"
          # Purchase -> Input IGST (#{GST Percentage}) Debit ( GST Amount )
          update_voucher(request[expense.report_id][voucher_purchase], gst_account_name, -gst_amount)
        else
          # Purchase -> Input CGST (#{GST Percentage/2}) Debit ( GST Amount/2 )
          cgst_account_name = "Input CGST #{gst_percentage / 2}"
          # Purchase -> Input IGST (#{GST Percentage}) Debit ( GST Amount )
          update_voucher(request[expense.report_id][voucher_purchase], cgst_account_name, -(gst_amount / 2))

          # Purchase -> Input SGST (#{GST Percentage/2}) Debit ( GST Amount/2 )
          sgst_account_name = "Input SGST #{gst_percentage / 2}"
          # Purchase -> Input IGST (#{GST Percentage}) Debit ( GST Amount )
          update_voucher(request[expense.report_id][voucher_purchase], sgst_account_name, -(gst_amount / 2))
        end
      else
        # Journal -> Debit ledger
        update_voucher(request[expense.report_id][voucher_journal], ledger_name, -expense_amount)
        # Journal -> Add expense amount to employee's account
        update_voucher(request[expense.report_id][voucher_journal], user, expense_amount)
      end
    end
    request
  end

  def self.update_voucher(voucher, ledger_name, amount)
    if voucher[:transactions].blank?
      voucher[:transactions] = {}
    end
    if voucher[:transactions][ledger_name].blank?
      voucher[:transactions][ledger_name] = 0
    end
    voucher[:transactions][ledger_name] += amount
  end

  def self.old_generate_request_for(expenses, configuration)
    request = {}
    expenses.reimbursable.each do |expense|
      if request[expense.report_id].blank?
        request[expense.report_id] = {
            date: ERB::Util.html_escape(configuration.date_for(expense)),
            user: ERB::Util.html_escape(expense.user.gl_config[:name]),
            purchase: {},
            journal: {},
            total_reimbursable_amount: 0
        }
      end

      has_gst = expense.has_gst?
      has_tds = expense.has_tds?

      party_account_name = expense.custom_fields.with_field_key('tally_party_name')&.first&.value&.value
      ledger_name = ERB::Util.html_escape expense.category.gl_name
      expense_amount = expense.amount.INR

      if has_tds
        tds_account_name = expense.tds_slab.name
        tds_amount = expense.tds_amount.INR
        reimbursable_amount = expense_amount - tds_amount

        # Purchase -> Ledger Debit (Expense Amount)
        if request[expense.report_id][:purchase][ledger_name].blank?
          request[expense.report_id][:purchase][ledger_name] = 0
        end
        request[expense.report_id][:purchase][ledger_name] -= expense_amount

        # Purchase -> Party A/C Credit ( Expense Amount - TDS Amount )
        if request[expense.report_id][:purchase][party_account_name].blank?
          request[expense.report_id][:purchase][party_account_name] = 0
        end
        request[expense.report_id][:purchase][party_account_name] += reimbursable_amount

        # Purchase -> TDS A/c Credit ( TDS Amount )
        if request[expense.report_id][:purchase][tds_account_name].blank?
          request[expense.report_id][:purchase][tds_account_name] = 0
        end
        request[expense.report_id][:purchase][tds_account_name] += tds_amount

        # Journal -> Debit party account
        if request[expense.report_id][:journal][party_account_name].blank?
          request[expense.report_id][:journal][party_account_name] = 0
        end
        request[expense.report_id][:journal][party_account_name] -= reimbursable_amount
        # Journal -> Add reimbursable amount to employee's account
        request[expense.report_id][:total_reimbursable_amount] += reimbursable_amount

      elsif has_gst
        # Journal -> Ledger Debit ( Expense Amount )
        if request[expense.report_id][:journal][ledger_name].blank?
          request[expense.report_id][:journal][ledger_name] = 0
        end
        request[expense.report_id][:journal][ledger_name] -= expense_amount

        # Journal -> Employee GL Code Credit ( Expense Amount )
        request[expense.report_id][:total_reimbursable_amount] += expense_amount

        # Purchase -> Ledger Debit ( Expense Amount )
        if request[expense.report_id][:purchase][ledger_name].blank?
          request[expense.report_id][:purchase][ledger_name] = 0
        end
        request[expense.report_id][:purchase][ledger_name] -= expense_amount

        # Purchase -> Party A/c Credit ( Expense Amount )
        if request[expense.report_id][:purchase][party_account_name].blank?
          request[expense.report_id][:purchase][party_account_name] = 0
        end
        request[expense.report_id][:purchase][party_account_name] += expense_amount

        gst_amount = expense.gst_amount.INR
        gst_percentage = expense.gst_percentage
        if expense.gst_type.igst?
          gst_account_name = "Input IGST #{gst_percentage}"
          # Purchase -> Input IGST (#{GST Percentage}) Debit ( GST Amount )
          if request[expense.report_id][:purchase][gst_account_name].blank?
            request[expense.report_id][:purchase][gst_account_name] = 0
          end
          request[expense.report_id][:purchase][gst_account_name] -= gst_amount
        else
          # Purchase -> Input CGST (#{GST Percentage/2}) Debit ( GST Amount/2 )
          cgst_account_name = "Input CGST #{gst_percentage / 2}"
          # Purchase -> Input IGST (#{GST Percentage}) Debit ( GST Amount )
          if request[expense.report_id][:purchase][cgst_account_name].blank?
            request[expense.report_id][:purchase][cgst_account_name] = 0
          end
          request[expense.report_id][:purchase][cgst_account_name] -= gst_amount / 2

          # Purchase -> Input SGST (#{GST Percentage/2}) Debit ( GST Amount/2 )
          sgst_account_name = "Input SGST #{gst_percentage / 2}"
          # Purchase -> Input IGST (#{GST Percentage}) Debit ( GST Amount )
          if request[expense.report_id][:purchase][sgst_account_name].blank?
            request[expense.report_id][:purchase][sgst_account_name] = 0
          end
          request[expense.report_id][:purchase][sgst_account_name] -= gst_amount / 2
        end
      else
        # Journal -> Debit ledger
        if request[expense.report_id][:journal][ledger_name].blank?
          request[expense.report_id][:journal][ledger_name] = 0
        end
        request[expense.report_id][:journal][ledger_name] -= expense_amount
        # Journal -> Add expense amount to employee's account
        request[expense.report_id][:total_reimbursable_amount] += expense_amount
      end
    end
    request
  end

# def self.generate_request_for(expenses)
#   request = {purchase: {}, journal: {}}
#
#   purchases request, expenses
#   journal_entries request, expenses
# end
#
# def self.journal_entries(request, expenses)
#   journal = request[:journal]
#   # Journal entries are created report wise. So group all expenses report wise
#   # Required format
#   # voucher -> One per report
#   # sum the amounts ledger wise and debit each ledger the sum of the ledger total
#   # Sum all reimbursable amounts and credit that to the employee's gl_code
#   expenses.reimbursable.each do |expense|
#     expense_gl_code = ERB::Util.html_escape expense.category.gl_name
#
#
#
#     expense_amount = (expense.amount.INR - expense.compute_tds_amount)
#
#     journal[expense.report_id] = {date: configuration.date_for(expense), user: ERB::Util.html_escape(expense.user.gl_config[:name]), ledgers: {}, total_amount: 0} if journal[expense.report_id].nil?
#     if journal[expense.report_id][:ledgers][expense_gl_code].nil?
#       journal[expense.report_id][:ledgers][expense_gl_code] = {amount: 0}
#     end
#
#     journal[expense.report_id][:ledgers][expense_gl_code][:amount] += expense_amount
#     journal[expense.report_id][:total_amount] += expense_amount
#   end
# end
#
# def self.purchases(request, expenses)
#
# end

end