class FinlyF.Views.AnalyticsIndex extends Backbone.View
  templateSkeleton: HandlebarsTemplates['finlyf/base/skeleton']

  #navbar
  templateNavbarSidebar: HandlebarsTemplates['finlyf/expenses/navbar/navbar_sidebar']
  templateNavbarMain: HandlebarsTemplates['finlyf/expenses/navbar/navbar_main']

  #sidebar
  templateSidebar: HandlebarsTemplates['finlyf/expenses/sidebar/sidebar']


  #main
  templateMain: HandlebarsTemplates['finlyf/expenses/crud/main']

  events:
    'click .navbar-btn-refresh': 'refetchCollection'
    'click .navbar-menu-li': 'navigate'
    'click .navbar-view-type': 'changeView'
    'click .btn-reset-filters': 'resetFilters'
    #Filters
    'keyup .filter-merchant': 'autoComplete'
    'click .btn-filter-expenses': 'filter'

  initialize: (options) ->
    if options
      @params = options.params || {}
    else
      @params = {}
    @params.view = @params.view || 'personal'
    _this = @
    @dump = []
    @collection = new FinlyF.Collections.Analytics()
    @collection.fetch({
      reset: true,
      data: _this.params,
      success: ->
      error: ->
        console.log "Couldn't fetch Successfully."
    })
    @collection.on('reset', @processItems, @)

  render: ->
    $(@el).html(@templateSkeleton({item: @params}))
    $(@el).find(".secondary-navbar .navbar-sidebar").html(@templateNavbarSidebar())

    $(@el).find(".secondary-navbar .navbar-main").html(@templateNavbarMain({item: @params}))


    $(@el).find(".sidebar").html(@templateSidebar({item: @params}))
    # category_select = $(@el).find(".filter-category-id")
    # options = $("#newExpenseCategory option")
    # for option in options
    #   $('<option/>', {
    #     value: $(option).attr('value')
    #     text: $(option).text()
    #   }).appendTo(category_select)
    FinlyF.structureActions(@el, @params)
    @

  processItems: ->
    #Append all the expenses
    # @dump = @collection.models.slice()
    # # console.log "Models - ", @collection.models.length
    $(@el).find("#items").html("")
    @collection.each(@appendItems, @)

    #Stop refresh spinner if spinning
    spinner = $(@el).find(".secondary-navbar .navbar-btn-refresh i")
    if $(spinner).hasClass("fa-spin")
      $(spinner).removeClass("fa-spin")

  appendItems: (item) ->
    #Creating view for each expense and appending them
    view_item = new FinlyF.Views.Analytic({
      model: item
      parent: @
    })
    $(@el).find("#items").append(view_item.render().el)

  refetchCollection: (e) ->
    #REFRESH
    #Spin refresh-spinner
    # console.log "Hi"
    _this = @

    if e
      target = e.currentTarget
      $(target).find("i").addClass("fa-spin")

    @collection.fetch({
      reset: true,
      data: _this.params,
      success: ->
        # _this.toggleLoadMore(_this.collection)
        # _this.dump.length = 0
        # _this.dump = _this.collection.models.slice()
        # _this.resetPageCount({selector: '.main .load-more', page: 1})

      error: ->
        console.log "Couldn't fetch successfully."
        $(target).find("i").removeClass("fa-spin")
    })

  resetFilters: ->
    params = {}
    params.view = @params.view
    FinlyF.primary_router.navigate('analytics/params=' + JSON.stringify(params), {trigger: true})

  filter: (e) ->
    if e
      e.preventDefault()
      target = $(e.currentTarget)

    sidebar = $(@el).find(".sidebar")
    params = {
      'filter_merchant': $(".sidebar .filter-merchant").val() || ""
      'filter_date[from]': $(".sidebar .filter-date-from").val() || ""
      'filter_date[to]': $(".sidebar .filter-date-to").val() || ""
      'filter_category_id': $(".sidebar .filter-category-id").val() || ""
      'filter_receipt': $(".sidebar .filter-receipt").val() || ""
    }

    filter_amount_value = $(".sidebar .filter-amount-value").val()
    filter_receipt = $(".sidebar .filter-receipt").val()

    if filter_amount_value
      params["filter_amount[value]"] = filter_amount_value
      params["filter_amount[type]"] = $(".sidebar .filter-amount-type").val()

    # console.log "Will navigate now."
    if @params.view
      params.view = @params.view

    if $(target).attr('data-navigate')
      if $.parseJSON($(target).attr('data-navigate')) == true
        #Filters by navigating to a Backbone route
        FinlyF.primary_router.navigate('analytics/params=' + JSON.stringify(params), {trigger: true})  
      else
        #Navigates by refetching & resetting collection with params
        @collection.fetch({
          reset: true,
          data: params,
          success: ->
            # console.log "Fetched all the data"
          error: ->
            console.log "Couldn't fetch Successfully."
        })



  autoComplete: (e) ->
    target = $(e.currentTarget)
    query = $(target).val()

    $(target).autocomplete({
      minLength: 2,
      source: (request, response) ->
        $.ajax({
          dataType: "json"
          type : 'get'
          url: '/autocomplete/merchant'
          data: 
            remote: "true"
            query: query
            # area: 'central'
          success: (data) ->
            response(data)
          error: (err) ->
            console.log err
        })
      select: (event, ui) ->
        # console.log "Selected."
    })


  navigate: (e) ->
    unless $(e.currentTarget).hasClass('non-backbone-link')
      e.preventDefault()
      FinlyF.navigate(e, @params)
    else
      return

  changeView: (e) ->
    e.preventDefault()
    FinlyF.changeView(e)