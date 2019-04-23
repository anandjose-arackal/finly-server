# this operation will initiate a 1Rs transaction in the background machine and
# return the data back to the application server that requested for it
class YesBankTransferProvider
  include Sidekiq::Worker
  sidekiq_options queue: :payments_critical_queue

  def perform(response_handle, params)
    queue = Struct.new(:queue).new(response_handle)
    begin
      # the params here will contain details about the payment - such as details about the beneficiary etc.
      indifferent_params = params.with_indifferent_access

    end
  end
end