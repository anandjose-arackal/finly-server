class BackgroundJobs::Bbps::BillValidation
  include Sidekiq::Worker
  sidekiq_options queue: :yes_bank_bbps


  def perform(response_handle, params)
    queue = Struct.new(:queue).new(response_handle)
    begin
      op = ::Bbps::BillValidation.call_async(params: params, current_user: User.first, wait: true)
      if op.success?
        ::Resque.enqueue(queue, {success: true, response: op})
      else
        ::Resque.enqueue(queue, {success: false, messages: op.messages})
      end
    rescue Exception => e
      ::Resque.enqueue(queue, {success: false, messages: e.message})
    end
  end
end