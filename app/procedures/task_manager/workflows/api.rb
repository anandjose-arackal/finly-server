# class API
#
#   trigger_type :event #:schedule
#   record Invoice
#   event 'invoice.submit'
#   conditions [{}]
#   schedule({
#                every: TaskSchedule::EVERY[:day],
#                hour: 12,
#                minute: 0,
#                day_of_the_week: TaskSchedule::DAY_OF_THE_WEEK[:monday],
#                day_of_the_month: 1
#            })
#   system :em, :vp
#   roles :invoice_initiator
#   users do
#
#   end
#   input do
#
#   end
#   rule -> (input) {}
#   action SubmitMailer
#   action SubmitSms
#
#   class SubmitMailer < Mailers::API
#
#   end
#
# end
#
# class SubmitOwnerTask
#
#   trigger :event #:schedule
#   event 'invoice.submit'
#   rule -> (data) do
#     invoice = data[:invoice]
#     skip! if invoice.blank?
#     skip! if invoice.status == InwardInvoiceStatus.id_for(:processing)
#   end
#   action SubmitMailer
#   action Sms::API do
#
#   end
#
#   class SubmitMailer < Mailers::API
#
#   end
#
# end
#
# class API
#
#   trigger :schedule
#   record Invoice
#   conditions [{}]
#   schedule(
#       {
#           every: TaskSchedule::EVERY[:day],
#           hour: 12,
#           minute: 0,
#           day_of_the_week: TaskSchedule::DAY_OF_THE_WEEK[:monday],
#           day_of_the_month: 1
#       }
#   )
#   roles :invoice_initiator
#   users do
#
#   end
#   input do
#
#   end
#   action SubmitMailer
#   action SubmitSms
#
#   class SubmitMailer < Mailers::API
#
#   end
#
# end