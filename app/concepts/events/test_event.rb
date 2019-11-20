class TestEvent
  include Events::Consumer

  consumes_event! 'invoice.update', consumer_key: 'Invoice.Update.Logs', name: 'Log invoice changes'

  def on_event(user, payload)
    debugger
  end

end