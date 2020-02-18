class TestTransaction < Transactions::API

  class EventOne
    include Events::Consumer

    consumes_event!('user.*', sync: false, options: {})

    def work(user, params)
      puts "Receive event 1 : #{user} params: #{params}"
    end

  end

  # class EventTwo
  #   include Events::Consumer
  #
  #   consumes_event!('user.*', sync: false, options: {})
  #
  #   def work(user, params)
  #     error_logger = Logger.new("#{Rails.root}/log/message_queue_test.log")
  #     error_logger.info("Receive event 2")
  #     puts "Receive event 2"
  #   end

  # end

end