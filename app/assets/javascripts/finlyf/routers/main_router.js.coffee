class FinlyF.Routers.Main extends Backbone.Router
  routes:
    # '': 'index'
    # ':params': 'index'
    '': 'expenses'
    'expenses': 'expenses'
    'expenses/params=:query': 'expenses'
    'reports': 'reports'
    'reports/params=:query': 'reports'
    'reports/action=:action': 'reportsAction'
    'receipts': 'receipts'
    'settlements': 'settlements'
    'settlements/params=:query': 'settlements'
    'settlements/:user': 'settlements_show'
    'settlements/:user/params=:query': 'settlements_show'

  initialize: ->
    # console.log "Step 1. Main router initialized."

  expenses: (query) ->
    # console.log 'Step 2.A. Route at /. Rending expenses.'
    if typeof query != 'undefined'
      params = JSON.parse(query)
    else
      params = {}
    view = new FinlyF.Views.ExpensesIndex({
      params: params
    })
    $("#backbone-container").html(view.render().el)
    @features()

  reports: (query, action) ->
    # if typeof action != 'undefined'
    #   actions = JSON.parse(query)

    if typeof query != 'undefined'
      params = JSON.parse(query)
    else
      params = {}
    view = new FinlyF.Views.ReportsIndex({
      params: params
    })
    $("#backbone-container").html(view.render().el)
    @features()

  receipts: ->
    # console.log 'Step 2.D. Route at /receipts'
    view = new FinlyF.Views.ReceiptsIndex()
    $("#backbone-container").html(view.render().el)
    @features()

  settlements: (query) ->
    # Admin & Finance view
    if typeof query != 'undefined'
      params = JSON.parse(query)
    else
      params = {}
    view = new FinlyF.Views.SettlementsIndex({
      user: user,
      params: params
    })
    $("#backbone-container").html(view.render().el)

  settlements_show: (user, query) ->
    # console.log user, query
    if typeof query != 'undefined'
      params = JSON.parse(query)
    else
      params = {}
    view = new FinlyF.Views.SettlementsIndex({
      user: user,
      params: params
    })
    $("#backbone-container").html(view.render().el)

  features: ->
    $(".datepicker").datepicker({
      dateFormat: "yy-mm-dd"
    })