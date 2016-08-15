class FinlyF.Routers.Expenses extends Backbone.Router

  routes:
    '': 'index'
    'expenses': 'expenses'

  index: ->
    console.log "Index Route"
    #Index all reports

  expenses: ->
    console.log "Expenses Route"
