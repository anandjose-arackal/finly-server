window.FinlyF =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  initialize: ->
    # console.log "Step 0. Starting FinlyF."
    @primary_router = new FinlyF.Routers.Main()
    Backbone.history.start()



$(document).ready ->
  FinlyF.initialize()

  #Routes From Main Navbar. Codes need refactoring.
  #Should be handled with backbone events. Not directly
  $("#primary-navbar li a").on 'click', (e) ->
    e.preventDefault()
    # console.log "You clicked Nav"
    FinlyF.primary_router.navigate($(this).attr('href'), {trigger: true})

