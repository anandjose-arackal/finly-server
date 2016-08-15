window.FinlyF =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  initialize: ->
    console.log "Starting FinlyF"
    main_router = new FinlyF.Routers.Expenses()
    Backbone.history.start()



$(document).ready ->
  FinlyF.initialize()
