class PersistMessageProcessor < ApplicationProcessor

  subscribes_to :itz_cash_test

  def on_message(message)
    logger.debug "PersistMessageProcessor received: " + message
  end

end
