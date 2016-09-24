class FinlyF.Routers.Main extends Backbone.Router
  routes:
    # '': 'index'
    # ':params': 'index'
    '': 'expenses'
    'expenses': 'expenses'
    'expenses/params=:query': 'expenses'
    'reports': 'reports'
    'reports/params=:query': 'reports'
    # 'reports/action=:action': 'reportsAction'
    'receipts': 'receipts'
    'receipts/params=:query': 'receipts'
    'requests': 'requests'
    'requests/params=:query': 'requests'
    'settlements': 'settlements'
    'settlements/params=:query': 'settlements'
    'settlements/:user': 'settlements_show'
    'settlements/:user/params=:query': 'settlements_show'
    'employees/params=:query': 'users'
    'employees': 'users'

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

    $("#primary-navbar a[href=expenses]").parent().addClass('active')

  reports: (query, action) ->
    console.log "hit router"
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
    $("#primary-navbar a[href=reports]").parent().addClass('active')

    if params.report_id
      view.showReport(params.report_id)

  receipts:(query) ->
    if typeof query != 'undefined'
      params = JSON.parse(query)
    else
      params = {}
    # console.log 'Step 2.D. Route at /receipts'
    view = new FinlyF.Views.ReceiptsIndex({ params: params })
    $("#backbone-container").html(view.render().el)
    @features()
    $("#primary-navbar a[href=receipts]").parent().addClass('active')

  requests: (query) ->
    console.log "routerd to request"
    if typeof query != 'undefined'
      params = JSON.parse(query)
    else
      params = {}
    view = new FinlyF.Views.RequestsIndex({
      params: params
    })
    $("#backbone-container").html(view.render().el)
    @features()
    $("#primary-navbar a[href=requests]").parent().addClass('active')

  settlements: (query) ->
    # Admin & Finance view
    if typeof query != 'undefined'
      params = JSON.parse(query)
    else
      params = {}
    view = new FinlyF.Views.SettlementsIndex({
      # user: user,
      params: params
    })
    $("#backbone-container").html(view.render().el)
    @features()
    $("#primary-navbar a[href=settlements]").parent().addClass('active')

  settlements_show: (user, query) ->
    # console.log "settlements show"
    # console.log user, query
    if typeof query != 'undefined'
      # console.log "we're here"
      if query != null
        params = JSON.parse(query)
      else
        params = {
          view_to_load: 'approved'
        }
    else
      params = {
        view_to_load: 'approved'
      }
    params.view = 'personal'
    console.log params
    view = new FinlyF.Views.SettlementsIndex({
      user: user,
      params: params
    })
    $("#backbone-container").html(view.render().el)
    @features()
    $("#primary-navbar a[href=settlements]").parent().addClass('active')

  users: (query)->
    # Admin & Finance view
    if typeof query != 'undefined'
      params = JSON.parse(query)
    else
      params = {}
    view = new FinlyF.Views.UsersIndex({
      params: params
    })
    $("#backbone-container").html(view.render().el)
    @features()
    $("#primary-navbar a[href=employees]").parent().addClass('active')

  features: ->
    $(".datepicker").datepicker({
      dateFormat: "yy-mm-dd"
    })