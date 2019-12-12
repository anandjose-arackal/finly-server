# class Analytics::Master::Transactions::Create < Transactions::API
#
#   schema do
#     params do
#       required(:record).filled
#     end
#   end
#
#   MASTER = {
#       InvoiceLineItem => Analytics::Master::Transactions::Contracts::InvoiceItem
#   }
#
#   # step Model(TransactionAp, :new)
#   step Contract::Build(builder: :build_contract)
#   step Contract::Validate()
#   step Contract::Persist()
#
#   def build_contract(options, model:, record:, **)
#     MASTER[record.class].new(model)
#   end
#
# end