module TestEvent

  class UpdateToTrail
    include Events::Consumer

    consumes_event! 'invoice.update', consumer_key: 'Invoice.Update.Logs', name: 'Log invoice changes'

    def on_event(user, payload)
    end
  end

  class CreateToTrail < UpdateToTrail
    include Events::Consumer

    consumes_event! 'invoice.create', consumer_key: 'Invoice.Create.Logs', name: 'Log invoice changes'
  end

end