window.FinlyF =
  Global: {
    templates: {}
  }
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  Config: {
    notification: {
      poll_time: 120 #in seconds
      per_page: 10 #
    }
  }
  initialize: ->
    FinlyF.Global.templates.templateBalance = HandlebarsTemplates['finlyf/global/myBalance']
    FinlyF.Global.templates.templateTransferFunds = HandlebarsTemplates['finlyf/global/transferFunds']
    FinlyF.Global.templates.templateTransferFundsFlow = HandlebarsTemplates['finlyf/global/transferFundsFlow']

    FinlyF.Global.templates.templateUserNavProfile = HandlebarsTemplates['finlyf/global/userNavProfile']
    FinlyF.Global.templates.templateNotifications = HandlebarsTemplates['finlyf/global/templateNotifications']
    FinlyF.Global.templates.templateNoResultsFound = HandlebarsTemplates['finlyf/global/noResultsFound']

    user = {
      name: $("#current_user_id").attr('data-user-name')
      email: $("#current_user_id").attr('data-user-email')
    }

    FinlyF.Global.current_user = user


    @primary_router = new FinlyF.Routers.Main()
    Backbone.history.start()

    # if window.notification_timer
    #   clearInterval(window.notification_timer)

    # $.ajax({
    #   url: '/users/' + $("#current_user_id").val()
    #   data:
    #     view: 'personal'
    #   dataType: 'json'
    #   success: (res) ->
    #     console.log res
    #     FinlyF.Global.current_user = res.user
    #     console.log FinlyF.Global.current_user
    #   error: (err) ->
    #     console.log "Error", err
    # })
    
    # console.log FinlyF.Global.current_user
    
  fetchNotifications: (container, page, replaceContent) ->
    if replaceContent
      $(container).find('.notifications-list').html("<div class='text-center' style='margin-top: 15px;'><i class='fa fa-spinner fa-spin' style='color: #999;'></i></div>")
    # console.log $(container).html()
    # console.log "Will fetch notifications now."
    data = {
      # view: params.view || 'personal',
      authenticity_token: $("#authenticity_token").val()
    }
    if page
      data.page = page

    $.ajax({
      dataType: "json"
      type : 'get'
      url: '/notifications'
      data: data
      success: (res) ->
        if res.length < 10
          $(container).find('.btn-load-more-notifications').attr('disabled', true).text("No More Notifications")
        else
          $(container).find('.btn-load-more-notifications').removeAttr('disabled').text("Load More").attr('data-page', page + 1)

        if replaceContent
          $(container).find('.navbar-notifications .notifications-list').html(FinlyF.Global.templates.templateNotifications({items: res}))
        else
          $(container).find('.navbar-notifications .notifications-list').append(FinlyF.Global.templates.templateNotifications({items: res}))
      error: (err) ->
        console.log err
    })


  structureActions: (el, params)->
    # console.log "Strucure action params", params
    unless params.view == 'personal'
      $("body").addClass("admin")
    else
      $("body").removeClass("admin")
    # Append user profile to the navbar dropdown
    profile_div = $(el).find(".navbar-user-dropdown-profile")
    # $(profile_div).html(FinlyF.Global.templates.templateUserNavProfile({user: FinlyF.Global.current_user}))

    $(profile_div).find('.navbar-user-dropdown-name').text(FinlyF.Global.current_user.name)
    $(profile_div).find('.navbar-user-dropdown-email').text(FinlyF.Global.current_user.email)


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

    # navbar_cog_container = $(el).find("#pri")
    navbar_cog = $(el).find("#primary-navbar .navbar-right .navbar-cog")
    menus = $("#navbar-cog-navigation-admin li")
    for menu in menus
      a = $(menu).find('a')
      if $(a).attr('data-profile')
      # if $(menu).find('a[href*="profile"]')
        # console.log "Found a profile page for", $(menu).html()
        $(profile_div).find('.li-my-account').html($(a).clone())
        # console.log $(navbar_cog).html()
      else
        $(navbar_cog).prepend($(menu).clone())

    $(navbar_right).find("#navbar-user-dropdown").on('shown.bs.dropdown', (e) ->
      _this = this
      user_id = $("#current_user_id").val()
      $.ajax({
        dataType: "json"
        type : 'get'
        url: '/users/' + user_id + '/balance'
        data:
          view: params.view || 'personal'
          authenticity_token: $("#authenticity_token").val()
          current_user_wallet: true
          current_user_card: true
          current_user_cash_in_hand: true
          virtual_account: true
        success: (data) ->
          $(_this).find('.navbar-balance').html(FinlyF.Global.templates.templateBalance({item: data}))

          $(".btn-load-unload-funds").on('click', (e) ->
            $("#modal-global-transfer").modal('show')
            $("#modal-global-transfer").find('.modal-body').html(FinlyF.Global.templates.templateTransferFunds({item: data}))
          )
        error: (err) ->
          console.log err
      })
    )

    # $(navbar_right).find("#navbar-user-dropdown").on('hide.bs.dropdown', (e) ->
    #   console.log "Closing", e
    #   target = $(e.currentTarget)
    #   if target.hasClass("keepopen") || target.parents(".keepopen").length
    #     return false # returning false should stop the dropdown from hiding.
    #   else
    #     return true
    # )

    ###################################
    # Notification
    ###################################

    #### Polling for notification count
    notification_area = $(navbar_right).find('#navbar-notification-dropdown')

    pollNotificationCount = ->
      $.ajax({
        url: '/notifications/unread'
        dataType: 'json'
        success: (res) ->
          if parseInt(res) > 0
            if typeof FinlyF.notification_count == "undefined"
              $(notification_area).removeAttr('data-initial').attr('data-replace', true)
              FinlyF.notification_count = res
            else
              if parseInt(res) > FinlyF.notification_count
                $(notification_area).attr('data-replace', true)
            $(navbar_right).find('#navbar-notification-count').text(res)
        error: (err) ->
          console.log "Err", err
        
      })


    # pollNotification()
    if window.notification_timer
      clearInterval(window.notification_timer)
    window.notification_timer = setInterval(pollNotificationCount, FinlyF.Config.notification.poll_time * 1000)

    #First time fetch
    pollNotificationCount()


    ## opening dropdown should start fetching
    $(navbar_right).find("#navbar-notification-dropdown").on('shown.bs.dropdown', (e) ->
      # console.log "Its working, this is ", this
      _this = this
      if $(this).attr('data-initial') == 'true'
        $(this).removeAttr('data-initial')
        FinlyF.fetchNotifications(_this, 1, true)
      else if $(this).attr('data-replace') == "true"
        $(this).removeAttr('data-replace')
        FinlyF.fetchNotifications(_this, 1, true)
      # else if

    )

    # Notification Codes ends

    #Sidebar
    $(el).find('.sidebar .filter-category-id').val(params.filter_category_id)
    $(el).find('.sidebar .filter-receipt').val(params.filter_receipt)
    $(el).find('.sidebar .filter-amount-type').val(params.filter_amount_type)
    $(el).find('.sidebar .filter-expense-type-id').val(params.filter_expense_type_id)

    # Dropdown Filters for settlements Admin and employees
    $(el).find(".dropdown-filters .filter-role").val(params.filter_role)
    $(el).find(".dropdown-filters .filter-state").val(params.filter_state)

    # Generalized events
    #### Load more and append notifications
    $(navbar_right).find('.btn-load-more-notifications').on('click', (e) ->
      e.preventDefault()
      target = e.currentTarget

      $(target).attr('disabled', true).html("<i class='fa fa-spinner fa-spin'></i>")
      # console.log "we reached here"

      container = $(e.currentTarget).closest('.navbar-notifications').parent()
      page = parseInt($(target).attr('data-page') || 0)

      $.when(FinlyF.fetchNotifications(container, page, false)).then(->
        # $(target).attr('disabled', false).text('Load More')
      )
      e.stopPropagation()
    )

    #### Mark all as read
    $(navbar_right).find('.btn-mark-notifications-read').on('click', (e) ->
      e.preventDefault()
      $.ajax({
        url: '/notifications/mark_all_read',
        dataType: 'json',
        success: (res) ->
          console.log res
          if res.success == true
            FinlyF.mark_all_read(navbar_right)
        error: (err) ->
          console.log "Err", err
      })
      e.stopPropagation()
    )

  mark_all_read: (container) ->
    notifications = $(container).find('.navbar-notifications .notifications-list .navbar-notification')
    for notification in notifications
      if $(notification).hasClass('unread')
          $(notification).removeClass('unread')
    $(container).find("#navbar-notification-count").text("")


  navigate: (e, attr)->
    clearInterval(FinlyF.notification_timer)
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
    # @userBalance()


  userBalance: ->
    $("#navbar-user-dropdown").attr("data-found", true)
    console.log "In user balance evetn"
    $("#navbar-user-dropdown").on('shown.bs.dropdown', (e) ->
      _this = this
      user_id = $("#current_user_id").val()
      $.ajax({
        dataType: "json"
        type : 'get'
        # url: '/settlements/summary?view_to_load=payments&view=personal'
        url: '/users/' + user_id + '/balance'
        data:
          # target_user_id: user_id
          authenticity_token: $("#authenticity_token").val()
          # current_user_all: true
          current_user_wallet: true
          current_user_card: true
          current_user_cash_in_hand: true
          virtual_account: true
          # view: 'admin'
        success: (data) ->
          console.log("hello there!1")
          $(_this).find('.navbar-balance').html(FinlyF.Global.templates.templateBalance({item: data}))
          console.log("hello there!")
          # Finly.Gobal.balance_data = data


          $(".btn-load-unload-funds").on('click', (e) ->
            console.log "click"
            # $("#modal-balance").modal('hide')
            # $.ajax({

            # })
            $("#modal-global-transfer").modal('show')
            $("#modal-global-transfer").find('.modal-body').html(FinlyF.Global.templates.templateTransferFunds({item: data}))
          )
          # console.log data
        error: (err) ->
          console.log err
      })
    )

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

  appendCategoriesTo: (target) ->
    $.ajax({
      url: '/categories'
      dataType: 'json'
      success: (res) ->
        for category in res
          $('<option/>', {
            value: category.id
            text: category.name
          }).appendTo(target) 
        return res
      error: (err) ->
        console.log "Err", err
    }) 

$(document).ready ->
  FinlyF.initialize()

  # #################
  #  Clicking inside dropdown with class 'no-hide-bs-dropdown' shouldn't close the dropdown
  $('.dropdown-menu .no-hide-bs-dropdown').click((e) ->
    e.stopPropagation()
  )
  # templateBalance = HandlebarsTemplates['finlyf/global/myBalance']
  # templateWalletToCard = HandlebarsTemplates['finlyf/global/walletToCard']
  # balance_data = {}

  # $("#navbar-user-dropdown").on('shown.bs.dropdown', (e) ->
  #   _this = this
  #   e.preventDefault()
  #   user_id = $(this).find(".modal-body").attr('data-user-id')
  #   $.ajax({
  #     dataType: "json"
  #     type : 'get'
  #     # url: '/settlements/summary?view_to_load=payments&view=personal'
  #     url: '/users/' + user_id + '/balance'
  #     data:
  #       # target_user_id: user_id
  #       authenticity_token: $("#authenticity_token").val()
  #       current_user_all: true
  #       current_user_wallet: true
  #       current_user_card: true
  #       current_user_cash_in_hand: true
  #       virtual_account: true
  #       # view: 'admin'
  #     success: (data) ->
  #       $(_this).find('.navbar-balance').html(templateBalance({item: data}))
  #       balance_data = data


  #       $(".btn-transfer-wallet-to-card").on('click', (e) ->
  #         # $("#modal-balance").modal('hide')
  #         # $.ajax({

  #         # })
  #         $("#modal-global-transfer").modal('show')
  #         $("#modal-global-transfer").find('.modal-body').html(templateWalletToCard({item: balance_data}))
  #       )
  #       # console.log data
  #     error: (err) ->
  #       console.log err
  #   })
  # )




  # $("#modal-balance").on("shown.bs.modal", (e) ->
  #   _this = this
  #   e.preventDefault()
  #   user_id = $(this).find(".modal-body").attr('data-user-id')
  #   $.ajax({
  #     dataType: "json"
  #     type : 'get'
  #     # url: '/settlements/summary?view_to_load=payments&view=personal'
  #     url: '/users/' + user_id + '/balance'
  #     data:
  #       # target_user_id: user_id
  #       authenticity_token: $("#authenticity_token").val()
  #       current_user_all: true
  #       current_user_wallet: true
  #       current_user_card: true
  #       current_user_cash_in_hand: true
  #       virtual_account: true
  #       # view: 'admin'
  #     success: (data) ->
  #       $(_this).find('.modal-body').html(templateBalance({item: data}))
  #       balance_data = data


  #       $(".btn-transfer-wallet-to-card").on('click', (e) ->
  #         $("#modal-balance").modal('hide')
  #         # $.ajax({

  #         # })
  #         $("#modal-global-transfer").modal('show')
  #         $("#modal-global-transfer").find('.modal-body').html(templateWalletToCard({item: balance_data}))
  #       )
  #       # console.log data
  #     error: (err) ->
  #       console.log err
  #   })
  # )

  # $(".btn-transfer-wallet-to-card").on('click', (e) ->
  #   $("#modal-balance").modal('hide')
  #   # $.ajax({

  #   # })
  #   $("#modal-global-transfer").modal('show')
  #   $("#modal-global-transfer").find('.modal-body').html(templateWalletToCard({item: balance_data}))
  # )
  confirmTransferFunds = (e) ->
    target = e.currentTarget
    $(target).attr('disabled', true)
    e.preventDefault()
    modal = $(target).closest('.modal')
    amount = $(modal).find('input[name=amount]').val()
    password = $(modal).find('input[type=password]').val()
    note = $(modal).find('textarea[name=note]').val()

    url = $(target).attr('data-url')


    to_user_id = $("#current_user_id").val()

    $.ajax({
      url: url,
      type: 'post'
      dataType: 'json'
      data: {
        amount: amount
        password: password
        note: note
        view: 'personal'
        to_user_id: to_user_id
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

  $("#modal-global-transfer").on('shown.bs.modal', (e) ->
    modal = this
    $("input[name=global-transfer-funds][type=radio]").on('change', (event_select_flow) ->
      target = event_select_flow.currentTarget

      transfer_flow_container = $(target).closest('.transfer-flow-container')
      $(transfer_flow_container).find('.transfer-flow-option label').removeClass('active')

      $(target).closest('label').addClass('active')


      user_id = $("#current_user_id").val()
      flow_container = $(this).closest('.modal').find('.global-transfer-funds')
      action_type = $(this).attr('data-action')
      data = {}
      data.type = action_type

      switch action_type
        when 'from_wallet_to_card'
          data.url = "/cards/update_balance?action_type=1&from_account=wallet&to_account=card&view=personal"
        when 'from_card_to_wallet'
          data.url = "/cards/update_balance?action_type=1&from_account=card&to_account=wallet&view=personal"
          # ...

      $(flow_container).html(FinlyF.Global.templates.templateTransferFundsFlow({item: data}))

      $.ajax({
        dataType: "json"
        type : 'get'
        url: '/users/' + user_id + '/balance'
        data:
          authenticity_token: $("#authenticity_token").val()
          current_user_wallet: true
          current_user_card: true
        success: (data) ->
          # console.log "Balance Data", data
          $(modal).find(".current_user_card_balance").html("&#8377;&nbsp;" + data.current_user_card)
          $(modal).find(".current_user_wallet_balance").html("&#8377;&nbsp;" + data.current_user_wallet)
          $(modal).find(".current_user_card_eligibility").html("&#8377;&nbsp;" + data.current_user_card_details.available_card_eligibility)
        error: (err) ->
          console.log err
      })

      $(".btn-global-transfer").on('click', (evt) ->
        confirmTransferFunds(evt)
      ) 
        
      
    )



    # $(".btn-global-transfer").on('click', (evt) ->
    #   $(this).attr('disabled', true)
    #   target = this
    #   evt.preventDefault()
    #   amount = $(modal).find('input[name=amount]').val()
    #   password = $(modal).find('input[type=password]').val()
    #   note = $(modal).find('textarea[name=note]').val()

    #   url = $(this).attr('data-url')

    #   $.ajax({
    #     url: url,
    #     type: 'post'
    #     dataType: 'json'
    #     data: {
    #       amount: amount
    #       password: password
    #       note: note
    #       view: 'personal'
    #       to_user_id: to_user_id
    #     }
    #     success: (res) ->
    #       FinlyF.snapNotify(res.messages)
    #       if res.success == true
    #         $(modal).modal('hide')
    #       else
    #         $(target).attr('disabled', false)
    #     error: (err) ->
    #       console.log "Error", err
    #       $(target).attr('disabled', false)
          
    #   })

    # )
  )
