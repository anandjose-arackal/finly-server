class FinlyF.Routers.Main extends Backbone.Router
  routes:
    '': 'index'
    'expenses': 'expenses'
    'reports': 'reports'
    'receipts': 'receipts'

  initialize: ->
    console.log "Step 1. Main router initialized."

  index: ->
    console.log 'Step 2.A. Route at /. Rending expenses.'
    view = new FinlyF.Views.ExpensesIndex()
    $("#main").html(view.render().el)

  expenses: ->
    console.log 'Step 2.B. Route at /expenses'

  reports: ->
    console.log 'Step 2.C. Route at /reports'

  receipts: ->
    console.log 'Step 2.D. Route at /receipts' 