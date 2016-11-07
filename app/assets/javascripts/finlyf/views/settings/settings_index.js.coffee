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
      FinlyF.primary_router.navigate('settings/params=' + JSON.stringify(@params), {trigger: false})

  render: ->
    $(@el).html(@templateSkeleton())
    $(@el).find(".sidebar").html(@templateSidebar({item: @params}))
    FinlyF.structureActions(@el, @params)
    @

  navigateTab: (e) ->
    e.preventDefault();
    a = e.currentTarget
    li = $(a).parent()
    lis = $(a).parent().siblings('li')

    $(lis).removeClass("active")
    $(li).addClass('active')

    tab = $(li).attr('data-tab-navigate')

    @params.tab = tab
    FinlyF.primary_router.navigate('settings/params=' + JSON.stringify(@params), {trigger: false})
