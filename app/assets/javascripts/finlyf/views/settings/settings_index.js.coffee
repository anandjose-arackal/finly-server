class FinlyF.Views.SettingsIndex extends Backbone.View
  #sidebar
  templateSidebar: HandlebarsTemplates['finlyf/settings/sidebar/sidebar']
  #main
  templateSkeleton: HandlebarsTemplates['finlyf/settings/base/skeleton']

  events:
    'click .navigate-tab li a': 'navigateTab'

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
    # console.log tab
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
