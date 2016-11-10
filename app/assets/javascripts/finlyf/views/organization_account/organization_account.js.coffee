class FinlyF.Views.OrganizationAccount extends Backbone.View
  #sidebar
  templateSidebar: HandlebarsTemplates['finlyf/organization_account/sidebar/sidebar']
  #main
  templateSkeleton: HandlebarsTemplates['finlyf/organization_account/base/skeleton']

  events:
    'click .navigate-tab li a': 'navigateTab'
    'submit form#form-add-category': 'addCategory'
    'click .btn-delete-category': 'deleteCategory'

    'submit form#form-add-policy': 'addPolicy'
    'click .btn-delete-policy': 'deletePolicy'

    'submit form#form-add-export-column': 'addExportColumn'
    'change select.select-export-preference-columns': 'showExportPreferenceUpdateOption'
    # 'change input.input-export-preference-name': 'showExportPreferenceUpdateOption'
    'input input.input-export-preference-name': 'showExportPreferenceUpdateOption'

    'submit form.form-update-export-preferences': 'updateExportPreference'
    'click .btn-delete-export-preference': 'deleteExportPreference'

  initialize: (options) ->
    if options
      @params = options.params || {}
    else
      @params = {}
    @params.view = @params.view || 'admin'
    unless @params.tab
      @params.tab = @params.tab || 'policies'
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

  addCategory: (e) ->
    e.preventDefault()
    _this = @
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
    })

  deleteCategory: (e) ->
    e.preventDefault()
    target = e.currentTarget
    _this = @

    url = $(target).attr('data-url')
    # console.log target, url
    $.ajax({
      url: url,
      type: "DELETE",
      dataType: 'json',
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          _this.fetchTabContent()
          # ohSnap("Successfully requested for a demo. Thank you.", {color: 'green', 'duration': '6000'});
        # else
          # ohSnap("Something went wrong. Please try again.", {color: 'red', 'duration': '6000'})
    })

  addPolicy: (e) ->
    e.preventDefault()
    _this = @
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
    })   


  deletePolicy: (e) ->
    e.preventDefault()
    target = e.currentTarget
    _this = @

    url = $(target).attr('data-url')
    # console.log target, url
    $.ajax({
      url: url,
      type: "DELETE",
      dataType: 'json',
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          _this.fetchTabContent()
          # ohSnap("Successfully requested for a demo. Thank you.", {color: 'green', 'duration': '6000'});
        # else
          # ohSnap("Something went wrong. Please try again.", {color: 'red', 'duration': '6000'})
    })

  addExportColumn: (e) ->
    e.preventDefault()
    console.log "Here"
    _this = @
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
    }) 

  updateExportPreference: (e) ->
    e.preventDefault()

    _this = @
    form = e.currentTarget

    url = $(form).attr('action')

    $.ajax({
      url: url,
      data: $(form).serialize(),
      type: "PUT",
      dataType: 'json',
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          _this.fetchTabContent()
    })

  deleteExportPreference: (e) ->
    e.preventDefault()
    console.log "Will delete the preference"
    target = e.currentTarget
    _this = @

    url = $(target).attr('data-url')
    # console.log target, url
    $.ajax({
      url: url,
      type: "DELETE",
      dataType: 'json',
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          _this.fetchTabContent()
          # ohSnap("Successfully requested for a demo. Thank you.", {color: 'green', 'duration': '6000'});
        # else
          # ohSnap("Something went wrong. Please try again.", {color: 'red', 'duration': '6000'})
    })



  showExportPreferenceUpdateOption: (e) ->
    target = e.currentTarget
    form = $(target).closest('form')

    button = $(form).find('.btn-update-export-preference')
    $(button).removeClass('hidden')