window.FinlyF =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  initialize: ->
    console.log "Step 0. Starting FinlyF."
    main_router = new FinlyF.Routers.Main()
    Backbone.history.start()



$(document).ready ->
  FinlyF.initialize()
