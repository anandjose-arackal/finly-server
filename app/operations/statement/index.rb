# class Statement::Index < Statement::Base
#
#   attr_accessor :items, :transactions
#
#   def init
#     load_selected_user
#     self.transactions = selected_user.card_transactions
#     self.items = []
#   end
#
#   def authorize
#     unless selected_user
#       raise_unauthorized_exception
#     end
#   end
#
#   def validate
#     if end_date > DateUtils.local_date
#       messages[:error] << "End Date cannot be in the future"
#     end
#   end
#
#   def process
#     transactions.each do |transaction|
#       self.items << {
#           date: transaction.date,
#           transaction_type: "Card Transaction",
#           merchant: transaction.merchant_name,
#           debit_amount: (transaction.transaction_type == "Debit") ? transaction.billing_amount_value : "N/A" ,
#           credit_amount: (transaction.transaction_type == "Credit") ? transaction.billing_amount_value : "N/A" ,
#           # balance: (0), # todo need to be decided
#           category: expense_category(transaction),
#           status: expense_status(transaction)
#       }
#     end
#   end
#
#   private
#
#   def expense_status(transaction)
#     expense = transaction.card_expense.expense rescue nil
#     unless expense
#       return "N/A"
#     end
#     if expense.expense_status_id == ExpenseStatus.unreported_id or expense.expense_status_id == ExpenseStatus.unsubmitted_id
#       return "Unverified"
#     elsif expense.expense_status_id == ExpenseStatus.submitted_id
#       if expense.report.approved? or expense.report.closed? or expense.report.reimbursed? or report.reimbursement_confirmed?
#         return "Verified"
#       else
#         return "Unverified"
#       end
#     end
#   end
#
#   def expense_category(transaction)
#     expense = transaction.card_expense.expense rescue nil
#     unless expense
#       return "N/A"
#     end
#     expense.category.name
#   end
#
# end