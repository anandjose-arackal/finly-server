class FinlyF.Routers.Main extends Backbone.Router
  routes:
    # '': 'index'
    # ':params': 'index'
    'expenses': 'expenses'
    'expenses/:query': 'index'
    'reports': 'reports'
    'reports/:query': 'reports'
    'receipts': 'receipts'

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
    $(".datepicker").datepicker({
      dateFormat: "yy-mm-dd"
    })

  reports: ->
    # console.log 'Step 2.C. Route at /reports'
    view = new FinlyF.Views.ReportsIndex()
    if typeof query != 'undefined'
      params = JSON.parse(query)
    else
      params = {}
    view = new FinlyF.Views.ReportsIndex({
      params: params
    })
    $("#backbone-container").html(view.render().el)

  receipts: ->
    console.log 'Step 2.D. Route at /receipts' 