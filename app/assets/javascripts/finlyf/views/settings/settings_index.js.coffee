class FinlyF.Views.SettingsIndex extends Backbone.View
  #sidebar
  templateSidebar: HandlebarsTemplates['finlyf/settings/sidebar/sidebar']
  #main
  templateSkeleton: HandlebarsTemplates['finlyf/settings/base/skeleton']

  events:
    'click .navigate-tab li a': 'navigateTab'
    'submit form#changePassword': 'changePassword'
    'click .btn-iframe-modal': 'openiFrame'

    'click .btn-card-update-status': 'prepareUpdateCardStatus'
    'click .btn-confirm-card-status': 'updateCardStatus'
    
  initialize: (options) ->
    console.log "init, ", options
    if options
      @params = options.params || {}
    else
      @params = {}
    @params.view = @params.view || 'personal'
    unless @params.tab
      @params.tab = @params.tab || 'profile'
      # FinlyF.primary_router.navigate('settings/params=' + JSON.stringify(@params), {trigger: false})


  render: ->
    $(@el).html(@templateSkeleton())
    $(@el).find(".sidebar").html(@templateSidebar({item: @params}))
    @fetchTabContent()
    FinlyF.structureActions(@el, @params)
    @

  navigateTab: (e) ->
    e.preventDefault();
    a = e.currentTarget
    li = $(a).parent()
    lis = $(a).parent().siblings('li')

    $(lis).removeClass("active")
    $(li).addClass('active')
    tab_name = $(li).attr('data-tab-navigate')
    @params.tab = tab_name
    @fetchTabContent()



    
    # FinlyF.primary_router.navigate('settings/params=' + JSON.stringify(@params), {trigger: false})

  fetchTabContent: ->
    # console.log "Fetching"
    main = $(@el).find(".main")
    current_tab = $(@el).find('.main #' + @params.tab)

    $(current_tab).removeClass('hidden').siblings(".row").addClass('hidden')
    FinlyF.startMainLoader(main)

    url = $(current_tab).attr('data-url')
    # console.log "inside"
    # if $(tab).find(".content-fetched")
    # console.log "hello"
    $.ajax({
      url: url,
      dataType: 'html',
      data: {
        user_id: $("#current_user_id").val()
      }
      success: (res) ->
        # console.log res
        FinlyF.stopMainLoader()
        $(current_tab).html(res)
      error: (err) ->
        console.log "Error", err
    })

  changePassword: (e) ->
    _this = @
    e.preventDefault()
    form = e.currentTarget
    url = $(form).attr('action')

    $.ajax({
      url: url,
      data: $(form).serialize(),
      type: "POST",
      dataType: 'json',
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          _this.fetchTabContent()
          # ohSnap("Successfully requested for a demo. Thank you.", {color: 'green', 'duration': '6000'});
        else
          ohSnap("Something went wrong. Please try again.", {color: 'red', 'duration': '6000'})
    })

  openiFrame: (e) ->
    target = e.currentTarget
    src = $(target).attr('data-src')

    modal = $(@el).find('#modal-iframe')
    $(modal).find('iframe').attr('src', src)

  prepareUpdateCardStatus: (e) ->
    @current_card_status = $(e.currentTarget).attr('data-card-status-type')
    modal = $(@el).find("#modal-confirm-card-status")
    modal_title = $(modal).find('.modal-title')

    if parseInt(@current_card_status) == 1
      $(modal_title).text("Unblock Card")
    else if parseInt(@current_card_status) == 0
      $(modal_title).text("Block Card")

    $(modal).find(".btn-confirm-card-status").attr('data-card-status-type', @current_card_status)

    $(modal).modal('show')

  updateCardStatus: (e) ->
    e.preventDefault()
    target = e.currentTarget
    _this = @
    target_text = $(target).text()
    $(target).attr('disabled', true).html("&nbsp;&nbsp;<i class='fa fa-spin fa-spinner'></i>&nbsp;&nbsp;")
    modal = $(target).closest('.modal')
  
    $.ajax({
      url: '/cards/update_status',
      type: "POST",
      dataType: 'json',
      data: {
        view: 'personal',
        user_id: $("#current_user_id").val(),
        status_type: _this.current_card_status,
        password: $(target).closest('.modal-body').find('input[type=password]').val()
      },
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          $(modal).modal('hide')
          _this.fetchTabContent()
          $(target).removeAttr('disabled').text(target_text)
          $(target).closest('.modal-body').find('input[type=password]').val("")
        else
          $(target).removeAttr('disabled').text(target_text)
      error: (err) ->
        $(target).removeAttr('disabled').text(target_text)
        console.log("ERror", err)
    })




