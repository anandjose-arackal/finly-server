class FinlyF.Views.AnalyticsIndex extends Backbone.View
  templateSkeleton: HandlebarsTemplates['finlyf/base/skeleton']

  #navbar
  templateNavbarSidebar: HandlebarsTemplates['finlyf/analytics/navbar/navbar_sidebar']
  templateNavbarMain: HandlebarsTemplates['finlyf/analytics/navbar/navbar_main']

  #sidebar
  templateSidebar: HandlebarsTemplates['finlyf/analytics/sidebar/sidebar']


  #main
  templateMain: HandlebarsTemplates['finlyf/analytics/crud/main']

  events:
    'click .navbar-btn-refresh': 'refetchCollection'
    'click .navbar-menu-li': 'navigate'
    'click .navbar-view-type': 'changeView'
    'click .btn-reset-filters': 'resetFilters'
    #Filters
    'change .select-show-for': 'showForOptions' 
    'keyup .filter-field': 'autoComplete'
    # 'keyup .filter-merchant': 'autoComplete'
    'click .btn-filter-expenses': 'filter'
    'click .filter-data-type': 'filterDataType'

    'click .load-more': 'loadMore'

  initialize: (options) ->
    if options
      @params = options.params || {}
    else
      @params = {}
    @params.view = @params.view || 'personal'
    @params.filter_analytics_type = @params.filter_analytics_type || 'category'
    _this = @
    @dump = []
    @collection = new FinlyF.Collections.Analytics()
    @collection.fetch({
      reset: true,
      data: _this.params,
      success: ->
        _this.toggleLoadMore(_this.collection)
      error: ->
        console.log "Couldn't fetch Successfully."
    })
    @collection.on('reset', @processItems, @)

  render: ->
    $(@el).html(@templateSkeleton({item: @params}))
    $(@el).find(".secondary-navbar .navbar-sidebar").html(@templateNavbarSidebar())

    $(@el).find(".secondary-navbar .navbar-main").html(@templateNavbarMain({item: @params}))
    @params.filter_date_from = @params['filter_date[from]']
    @params.filter_date_to = @params['filter_date[to]']
    @params.indexOnly = false#REF==2I


    $(@el).find(".sidebar").html(@templateSidebar({item: @params}))
    $(@el).find(".sidebar .select-show-for").val(@params.filter_show_for)
    $(@el).find('.main').html(@templateMain())
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
    arr = @collection.pluck('item_total')
    # console.log arr
    # console.log arr.filter(Boolean)
    # console.log arr
    @max_total = Math.max.apply(Math,arr.filter(Boolean))
    $(@el).find("#items").html("")
    @collection.each(@appendItems, @)

    FinlyF.stopMainLoader()

    #Stop refresh spinner if spinning
    spinner = $(@el).find(".secondary-navbar .navbar-btn-refresh i")
    if $(spinner).hasClass("fa-spin")
      $(spinner).removeClass("fa-spin")

  appendItems: (item) ->
    unless item.get('meta')
      item.set('max_total', @max_total)
    #Creating view for each expense and appending them
    view_item = new FinlyF.Views.Analytic({
      model: item
      parent: @
    })
    if item.get('meta')
      $(@el).find("#items-total").append(view_item.render().el)
    else
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
        _this.toggleLoadMore(_this.collection)
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
    navbar_main = $(@el).find(".navbar-main")

    expenses_status_ids = []

    $(".sidebar .filter-expense-status-id:checked").each( ->
      expenses_status_ids.push($(this).val())
    )

    expenses_type_ids = []

    $(".sidebar .filter-expense-type-id:checked").each( ->
      expenses_type_ids.push($(this).val())
    )



    params = {
      'filter_merchant': $(".sidebar .filter-merchant").val() || ""
      'filter_date[from]': $(".sidebar .filter-date-from").val() || ""
      'filter_date[to]': $(".sidebar .filter-date-to").val() || ""
      'filter_user_id': $(".sidebar .filter-user").attr('data-item-id') || ""
      'filter_user_name': $(".sidebar .filter-user").val() || ""
      'filter_show_for': $(".sidebar .select-show-for").val() || ""
      'filter_analytics_type': $(navbar_main).find('li.filter-data-type.active').attr('data-show-type') || "category"
      'filter_expense_status_id':  expenses_status_ids
      'filter_expense_type_id': expenses_type_ids
    }

    # console.log "Will navigate now.", params
    if @params.view
      params.view = @params.view

    FinlyF.primary_router.navigate('analytics/params=' + JSON.stringify(params), {trigger: true})  
   
  filterDataType: (e) ->
    e.preventDefault()
    target = e.currentTarget
    $(target).addClass('active').siblings().removeClass('active')
    @filter()


  autoComplete: (e) ->
    _this = @
    target = $(e.currentTarget)
    query = $(target).val()
    field = $(target).attr('data-field')

    $(target).autocomplete({
      minLength: 2,
      source: (request, response) ->
        $.ajax({
          dataType: "json"
          type : 'get'
          url: '/autocomplete/' + field
          data:
            view: _this.params.view
            remote: "true"
            filter_search: query
          success: (data) ->
            response(data)
          error: (err) ->
            console.log err
        })

      focus: (event, ui) ->
        $(event.target).val(ui.item.label)
        $(event.target).attr('data-item-id', ui.item.value)
        return false

      select: (event, ui) ->
        $(event.target).val(ui.item.label)
        $(event.target).attr('data-item-id', ui.item.value)
        return false

    })

  showForOptions: (e) ->
    target = e.currentTarget
    # console.log target
    sidebar = $(target).closest('.sidebar')
    show_for = $(target).val()
    if show_for == 'user'
      $(sidebar).find('.search_by_user').slideDown()
    else
      $(sidebar).find('.search_by_user').slideUp()


  navigate: (e) ->
    unless $(e.currentTarget).hasClass('non-backbone-link')
      e.preventDefault()
      FinlyF.navigate(e, @params)
    else
      return

  changeView: (e) ->
    e.preventDefault()
    FinlyF.changeView(e)

  loadMore: (e) ->
    _this = @
    target = $(e.currentTarget)
    $(target).find('i').removeClass('fa-cloud-download').addClass('fa-spinner fa-pulse')
    $(target).find('span').text('Loading....')
    @params.page = (parseInt($(target).attr("data-page")) || 0 ) + 1

    @collection.fetch({
      data: _this.params,
      reset: false,
      success: ->
        _this.toggleLoadMore(_this.collection)
        $(target).find('i').addClass('fa-cloud-download').removeClass('fa-spinner fa-pulse')
        $(target).find('span').text('Load More')
        _this.resetPageCount({target: target, page: _this.params.page })

        _this.dump = (_this.dump.concat(_this.collection.models.slice())).slice()

        _this.collection.reset(_this.dump)

      error: ->
        console.log "Couldn't fetch Successfully."
    })

  toggleLoadMore: (collection) ->
    # console.log "Loading", collection.models.length
    if collection.models.length < 20
      # console.log "Should hide"
      $(@el).find('.load-more').css('display', 'none')
    else
      $(@el).find('.load-more').css('display', 'inline')

  resetPageCount: (options) ->
    if options.target
      $(options.target).attr('data-page', options.page)
    else if options.selector
      $(options.selector).attr('data-page', options.page)
    else
      $('.main .load-more').attr('data-page', options.page)

