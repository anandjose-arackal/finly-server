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
    # console.log "menus", params
    dropdown = $(el).find('#primary-navbar .menu-nav-views-dropdown')
    if views.length == 1
      $(dropdown).parent().hide()
    else
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
      when "finance_manager"
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
    $(el).find('.sidebar .filter-category-id').val(params.filter_category_id)
    $(el).find('.sidebar .filter-receipt').val(params.filter_receipt)
    $(el).find('.sidebar .filter-amount-type').val(params.filter_amount_type)
    $(el).find('.sidebar .filter-expense-type-id').val(params.filter_expense_type_id)

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
    console.log "From snap", obj
    ohSnapX()
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
          # console.log "Message ", message, "Color:", color, "container", container
          ohSnap(message, {color: color, 'duration': '9000', 'container-id': container})

  startMainLoader: (el) ->
    $(el).addClass("main-loader")

  stopMainLoader: (el) ->
    if el
      $(el).removeClass('main-loader')
    else
      $(".main-loader").removeClass("main-loader")

$(document).ready ->
  FinlyF.initialize()
  templateBalance = HandlebarsTemplates['finlyf/global/myBalance']
  templateWalletToCard = HandlebarsTemplates['finlyf/global/walletToCard']
  balance_data = {}
  $("#modal-balance").on("shown.bs.modal", (e) ->
    _this = this
    e.preventDefault()
    user_id = $(this).find(".modal-body").attr('data-user-id')
    $.ajax({
      dataType: "json"
      type : 'get'
      # url: '/settlements/summary?view_to_load=payments&view=personal'
      url: '/users/' + user_id + '/balance'
      data:
        # target_user_id: user_id
        authenticity_token: $("#authenticity_token").val()
        current_user_all: true
        current_user_wallet: true
        current_user_card: true
        current_user_cash_in_hand: true
        virtual_account: true
        # view: 'admin'
      success: (data) ->
        $(_this).find('.modal-body').html(templateBalance({item: data}))
        balance_data = data


        $(".btn-transfer-wallet-to-card").on('click', (e) ->
          $("#modal-balance").modal('hide')
          # $.ajax({

          # })
          $("#modal-global-transfer").modal('show')
          $("#modal-global-transfer").find('.modal-body').html(templateWalletToCard({item: balance_data}))
        )
        # console.log data
      error: (err) ->
        console.log err
    })
  )

  # $(".btn-transfer-wallet-to-card").on('click', (e) ->
  #   $("#modal-balance").modal('hide')
  #   # $.ajax({

  #   # })
  #   $("#modal-global-transfer").modal('show')
  #   $("#modal-global-transfer").find('.modal-body').html(templateWalletToCard({item: balance_data}))
  # )

  $("#modal-global-transfer").on('shown.bs.modal', (e) ->
    modal = this
    to_user_id = $(modal).attr('data-user-id')
    $(".btn-transfer-wallet-to-card").on('click', (evt) ->
      $(this).attr('disabled', true)
      target = this
      evt.preventDefault()
      amount = $(modal).find('input[name=amount]').val()
      password = $(modal).find('input[type=password]').val()

      url = $(this).attr('data-url')

      $.ajax({
        url: url,
        type: 'post'
        dataType: 'json'
        data: {
          amount: amount
          password: password
          view: 'personal'
          to_user_id: 1
        }
        success: (res) ->
          FinlyF.snapNotify(res.messages)
          if res.success == true
            $(modal).modal('hide')
          else
            $(target).attr('disabled', false)
        error: (err) ->
          console.log "Error", err
          $(target).attr('disabled', false)
          
      })

    )

  )
