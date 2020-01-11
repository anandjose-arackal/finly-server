MQ_PUBLISHER = Bunny.new
Sneakers.configure :connection => MQ_PUBLISHER, workers: 1