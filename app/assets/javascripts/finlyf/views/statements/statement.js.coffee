class FinlyF.Views.Statement extends Backbone.View
  templateSkeleton: HandlebarsTemplates['finlyf/statements/base/skeleton']
  templateSidebar: HandlebarsTemplates['finlyf/statements/sidebar/sidebar']
  templateNavbarMain: HandlebarsTemplates['finlyf/statements/navbar/navbar_main']

  templateMain: HandlebarsTemplates['finlyf/statements/crud/main']

  events:
    'click .filter-statements': 'filterStatements'

  initialize: (options) ->
    if options
      @user = options.user
      @params = options.params
      console.log "options", options

    $.ajax({
      url: '/statements/' + @user + '/summary'
      dataType: 'json'

      success: (res) ->
        populateSummary(res)
      error: (err) ->
        console.log "Err", err
    })


  render: ->
    $(@el).html(@templateSkeleton({item: @params}))
    $(@el).find(".sidebar").html(@templateSidebar())
    # $(@el).find(".navbar-main").html(@templateNavbarMain())
    $(@el).find(".main").html(@templateMain())
    # $(@el).find(".settlements-index").html(@templateMainPayments())

    FinlyF.structureActions(@el, @params)
    @


  populateSummary: (item) ->
    $(@el).find(".main").html(templateMain({item: item}))
  filterStatements: (e) ->
    e.preventDefault()
    target = e.currentTarget

    @params.filter_state = parseInt($(target).attr('data-filter-state')) 

