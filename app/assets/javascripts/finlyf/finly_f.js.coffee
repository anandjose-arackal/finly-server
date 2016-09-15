window.FinlyF =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  initialize: ->
    # console.log "Step 0. Starting FinlyF."
    @primary_router = new FinlyF.Routers.Main()
    Backbone.history.start()

  structureActions: (el, params)->
    company_name = $("#data-nav-company").val()
    $(el).find(".company-name").text(company_name)

    views = $("#menu-nav-views-dropdown li")
    console.log "menus", params
    dropdown = $(el).find('#primary-navbar .menu-nav-views-dropdown')
    for view in views
      $(dropdown).append($(view).clone())

    navbar_right = $(el).find("#primary-navbar .navbar-right")
    switch params.view
      when "admin"
        menus = $("#navbar-menu-navigation-" + "admin li")
        for menu in menus
          $(navbar_right).prepend($(menu).clone())
        $(el).find('.current-view-type').text("Admin View")
      when "personal"
        menus = $("#navbar-menu-navigation-" + "personal li")
        for menu in menus
          $(navbar_right).prepend($(menu).clone())
        $(el).find('.current-view-type').text("Personal View")
      when "finance"
        menus = $("#navbar-menu-navigation-" + "finance li")
        for menu in menus
          $(navbar_right).prepend($(menu).clone())
        $(el).find('.current-view-type').text("Finance View")
      when "manager"
        menus = $("#navbar-menu-navigation-" + "manager li")
        for menu in menus
          $(navbar_right).prepend($(menu).clone())
        $(el).find('.current-view-type').text("Manager View")
      else
        menus = $("#navbar-menu-navigation-" + "personal li")
        for menu in menus
          $(navbar_right).prepend($(menu).clone())
        $(el).find('.current-view-type').text("Personal View")

    navbar_cog = $(el).find("#primary-navbar .navbar-right .navbar-cog")
    menus = $("#navbar-cog-navigation-admin li")
    for menu in menus
      $(navbar_cog).prepend($(menu).clone())

    #Sidebar
    # $(el).find('.sidebar .filter-category-id').val(params.filter_category_id)
    # $(el).find('.sidebar .filter-receipt').val(params.filter_receipt)

  navigate: (e, attr)->
    target = e.currentTarget
    path = $(target).attr('data-path')

    if attr.view
      params = {
        'view': attr.view
      }
      FinlyF.primary_router.navigate(path + "/params=" + JSON.stringify(params), {trigger: true})
    else
      FinlyF.primary_router.navigate(path, {trigger: true})
    # console.log "Will navigate to ", path

  changeView: (e) ->
    e.preventDefault()
    target = e.currentTarget
    view_type = $(target).attr('data-view-type')
    # console.log view_type
    params = {
      view: view_type
    }

    unless view_type == "personal"
      FinlyF.primary_router.navigate('reports/params=' + JSON.stringify(params), {trigger: true})
    else
      FinlyF.primary_router.navigate('expenses', {trigger: true})

  snapNotify: (obj) ->
    console.log obj
    for type, messages of obj
      switch type
        when 'error'
          color = 'red'
          container = 'ohsnap-priority'
        when 'success'
          color = 'green'
          container = 'ohsnap'
        when 'failure'
          color: 'orange'
          container = 'ohsnap-priority'
        when 'message'
          color: 'blue'
          container = 'ohsnap'
        when 'notice'
          color: 'blue'
          container = 'ohsnap'
        else
          color: 'blue'
          container = 'ohsnap'
      if messages.length
        for message in messages
          console.log "Message ", message, "Color:", color, "container", container
          ohSnap(message, {color: color, 'duration': '100000', 'container-id': container});

$(document).ready ->
  FinlyF.initialize()

