# 1 report = 1 voucher
# Only reimbursable expenses are considered
# Ledger = gl_code picked up from expense category
# Employee GL Code = GL Code picked up from user.gl_config[:name]
#
# Case 1: No TDS or GST
#   Journal:
#     Ledger debit ( Expense amount )
#     Employee GL Code Credit ( Expense Amount )
#

class Personalizer::Adapters::Company137::Tally::TallyTemplate
  include ERB::Util

  def self.generate_request_for(expenses, configuration)
    request = {}
    expenses.reimbursable.each do |expense|
      if request[expense.report_id].blank?
        request[expense.report_id] = {}
      end

      date = ERB::Util.html_escape(configuration.date_for(expense))
      user = ERB::Util.html_escape(expense.user.name)

      ledger_name = ERB::Util.html_escape expense.category.gl_name
      expense_amount = expense.amount.INR

      voucher_journal = 'Journal Vendor (18-19)'

      if request[expense.report_id][voucher_journal].blank?
        request[expense.report_id][voucher_journal] = {
            name: voucher_journal,
            date: date,
            date_start: expense.date,
            date_end: expense.date,
            period: "",
            narration: "",
            user: user,
            transactions: {}
        }
      end

      # Journal -> Debit ledger
      update_voucher(request[expense.report_id][voucher_journal], ledger_name, -expense_amount)
      # Journal -> Add expense amount to employee's account
      update_voucher(request[expense.report_id][voucher_journal], user, expense_amount)

      if request[expense.report_id][voucher_journal][:date_start] > expense.date
        request[expense.report_id][voucher_journal][:date_start] = expense.date
      end

      if request[expense.report_id][voucher_journal][:date_end] < expense.date
        request[expense.report_id][voucher_journal][:date_end] = expense.date
      end

      if request[expense.report_id][voucher_journal][:date_start].beginning_of_day == request[expense.report_id][voucher_journal][:date_end].beginning_of_day
        request[expense.report_id][voucher_journal][:period] = "#{request[expense.report_id][voucher_journal][:date_start].strftime("%d.%m.%Y")}"
      else
        request[expense.report_id][voucher_journal][:period] = "#{request[expense.report_id][voucher_journal][:date_start].strftime("%d.%m.%Y")} to #{request[expense.report_id][voucher_journal][:date_end].strftime("%d.%m.%Y")}"
      end

      request[expense.report_id][voucher_journal][:narration] = "Being exp of #{user} for the period of #{request[expense.report_id][voucher_journal][:period]}"
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

end