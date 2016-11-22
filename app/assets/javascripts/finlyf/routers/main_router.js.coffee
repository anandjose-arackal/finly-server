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

    'statements/:user/params=:query': 'statements'
    'employees/params=:query': 'users'
    'employees': 'users'
    'analytics': 'analytics'
    'analytics/params=:query': 'analytics'


    # Non backboned pages
    'settings': 'settings'
    'settings/params=:query': 'settings'

    'organization_account': 'organization_account'
    'organization_account/params=:query': 'organization_account'

    'policies/:id': 'policies_show'
    'policies/:id/params=:query': 'policies_show'


  initialize: ->
    # body = $("body")
    # FinlyF.startMainLoader(body)
    # console.log "Step 1. Main router initialized."

  expenses: (query) ->
    # body = $("body")
    # FinlyF.startMainLoader(body)
    # console.log 'Step 2.A. Route at /. Rending expenses.'
    if typeof query != 'undefined'
      params = JSON.parse(query)
    else
      params = {}
    view = new FinlyF.Views.ExpensesIndex({
      params: params
    })
    $("#backbone-container").html(view.render().el)
    main = $("#backbone-container .main")
    FinlyF.startMainLoader(main)
    @features()

    $("#primary-navbar a.navbar-menu-li[href^='\\#expenses']").parent().addClass('active')

  reports: (query, action) ->
    # body = $("body")
    # FinlyF.startMainLoader(body)
    # console.log "hit router"
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
    main = $("#backbone-container .main")
    FinlyF.startMainLoader(main)
    @features()
    $("#primary-navbar a.navbar-menu-li[href^='\\#reports']").parent().addClass('active')

    if params.report_id
      view.showReport(params.report_id)

  receipts:(query) ->
    # body = $("body")
    # FinlyF.startMainLoader(body)
    if typeof query != 'undefined'
      params = JSON.parse(query)
    else
      params = {}
    # console.log 'Step 2.D. Route at /receipts'
    view = new FinlyF.Views.ReceiptsIndex({ params: params })
    $("#backbone-container").html(view.render().el)
    main = $("#backbone-container .main")
    FinlyF.startMainLoader(main)
    @features()
    $("#primary-navbar a.navbar-menu-li[href^='\\#receipts']").parent().addClass('active')

  requests: (query) ->
    # body = $("body")
    # FinlyF.startMainLoader(body)
    console.log "routerd to request"
    if typeof query != 'undefined'
      params = JSON.parse(query)
    else
      params = {}
    view = new FinlyF.Views.RequestsIndex({
      params: params
    })
    $("#backbone-container").html(view.render().el)
    main = $("#backbone-container .main")
    FinlyF.startMainLoader(main)
    @features()
    $("#primary-navbar a.navbar-menu-li[href^='\\#requests']").parent().addClass('active')

  settlements: (query) ->
    # body = $("body")
    # FinlyF.startMainLoader(body)
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
    main = $("#backbone-container .main")
    FinlyF.startMainLoader(main)
    @features()
    $("#primary-navbar a.navbar-menu-li[href^='\\#settlements']").parent().addClass('active')

  settlements_show: (user, query) ->
    # body = $("body")
    # FinlyF.startMainLoader(body)
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
    summary = $("#backbone-container  .main .summary")
    main = $("#backbone-container .settlements-content")
    FinlyF.startMainLoader(main)
    FinlyF.startMainLoader(summary)
    @features()
    $("#primary-navbar a.navbar-menu-li[href^='\\#settlements']").parent().addClass('active')

  statements: (user, query) ->
    console.log "hitting the route"
    if typeof query != 'undefined'
      if query != null
        params = JSON.parse(query)
      else
        params = {}
    else
      params = {}
    view = new FinlyF.Views.Statement({
      user: user,
      params: params
    })
    $("#backbone-container").html(view.render().el)
    # summary = $("#backbone-container  .main .summary")
    # main = $("#backbone-container .settlements-content")
    # FinlyF.startMainLoader(main)
    # FinlyF.startMainLoader(summary)
    @features()

  users: (query)->
    # body = $("body")
    # FinlyF.startMainLoader(body)
    # Admin & Finance view
    if typeof query != 'undefined'
      params = JSON.parse(query)
    else
      params = {}
    view = new FinlyF.Views.UsersIndex({
      params: params
    })
    $("#backbone-container").html(view.render().el)
    # Start Main loader
    main = $("#backbone-container .sidebar")
    FinlyF.startMainLoader(main)
    @features()
    $("#primary-navbar a.navbar-menu-li[href^='\\#employees']").parent().addClass('active')

  analytics: (query) ->
    # body = $("body")
    # FinlyF.startMainLoader(body)
    # console.log 'Step 2.A. Route at /. Rending expenses.'
    if typeof query != 'undefined'
      params = JSON.parse(query)
    else
      params = {}
    view = new FinlyF.Views.AnalyticsIndex({
      params: params
    })
    $("#backbone-container").html(view.render().el)
    main = $("#backbone-container .main")
    FinlyF.startMainLoader(main)
    @features()

    $("#primary-navbar a.navbar-menu-li[href^='\\#analytics']").parent().addClass('active')

  # account: (user, query) ->
  # settings: (user) ->
  settings: (query)->
    if typeof query != 'undefined'
      params = JSON.parse(query)
    else
      params = {}

    view = new FinlyF.Views.SettingsIndex({
      params: params
    })
    $("#backbone-container").html(view.render().el)
    @features()

  organization_account: (query) ->
    console.log "Organization Account"
    if typeof query != 'undefined'
      params = JSON.parse(query)
    else
      params = {}

    view = new FinlyF.Views.OrganizationAccount({
      params: params
    })
    $("#backbone-container").html(view.render().el)
    @features()

  policies_show: (id, query) ->
    if typeof query != 'undefined'
      # console.log "we're here"
      if query != null
        params = JSON.parse(query)
      else
        params = {
          view: 'admin'
        }
    else
      params = {
        view: 'admin'
      }
    console.log params
    view = new FinlyF.Views.Policy({
      id: id,
      params: params
    })
    $("#backbone-container").html(view.render().el)
    @features()

  features: ->
    $(".datepicker").datepicker({
      dateFormat: "yy-mm-dd"
    })
