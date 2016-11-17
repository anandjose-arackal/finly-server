class FinlyF.Views.Policy extends Backbone.View
  #sidebar
  templateSidebar: HandlebarsTemplates['finlyf/policies/sidebar/sidebar']
  #main
  templateSkeleton: HandlebarsTemplates['finlyf/policies/base/skeleton']

  events:
    'click .navigate-tab li a': 'navigateTab'
    'click .btn-new-rule': 'newRule'

    'submit form#form-create-rule': 'createRule'
    'hidden.bs.modal #modal-create-rule': 'clearDiv'
    'submit form.form-remove-rule': 'removeRule'

  initialize: (options) ->
    @policy_id = options.id
    console.log options
    if options
      @params = options.params || {}
    else
      @params = {}
    @params.view = @params.view || 'admin'
    unless @params.tab
      @params.tab = @params.tab || 'expense_rules'
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
        id: @policy_id
        view: @params.view
      }
      success: (res) ->
        # console.log res
        FinlyF.stopMainLoader()
        $(current_tab).html(res)
      error: (err) ->
        console.log "Error", err
    })

  newRule: (e) ->
    e.preventDefault()
    target = e.currentTarget

    rule_type = $(target).attr('data-rule-type')
    rule_category = $(target).attr('data-rule-category')
    modal = $(@el).find('#modal-create-rule')

    $(modal).modal('show')

    $.ajax({
      url: '/policies/create_rule',
      data: {
        id: @policy_id,
        view: @params.view
        rule_type: rule_type
        rule_category: rule_category
      },
      dataType: 'html',
      success: (res) ->
        $(modal).html(res)
      error: (err) ->
        $(modal).modal('hide')
        alert("Oops! Something went wrong. Please try again.")
    })

  createRule: (e) ->
    e.preventDefault()
    _this = @
    form = e.currentTarget

    modal = $(@el).find('#modal-create-rule')

    url = $(form).attr('action')

    $.ajax({
      url: url,
      data: $(form).serialize(),
      type: "POST",
      dataType: 'json',
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          $(modal).modal('hide')
          _this.fetchTabContent()
          # ohSnap("Successfully requested for a demo. Thank you.", {color: 'green', 'duration': '6000'});
    })

  removeRule: (e) ->
    e.preventDefault()
    _this = @

    form = e.currentTarget

    modal = $(@el).find('#modal-create-rule')

    url = $(form).attr('action')

    $.ajax({
      url: url,
      data: $(form).serialize(),
      type: "DELETE",
      dataType: 'json',
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          _this.fetchTabContent()
          # ohSnap("Successfully requested for a demo. Thank you.", {color: 'green', 'duration': '6000'});
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

  clearDiv: (e) ->
    console.log "Clearing div"
    target = e.currentTarget
    $(target).html("")