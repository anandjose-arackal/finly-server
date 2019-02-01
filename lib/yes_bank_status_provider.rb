class YesBankStatusProvider
  include Sidekiq::Worker
  sidekiq_options queue: :payments_critical_queue

   LOGGER = Logger.new(STDOUT)

  def perform(response_handle, params)
    queue = Struct.new(:queue).new(response_handle)
    begin

      op = YesBankApi::Status::GetStatus.(params)
      if op.success?
        status = op.status
        Resque.enqueue(queue, {success: true, status: status})
      else
        Resque.enqueue(queue, {success: false, status: nil, messages: op.messages[:error]})
      end
    rescue Exception => e
      Resque.enqueue(queue, {success: false, status: nil, messages: e.message})
    end
  end
end