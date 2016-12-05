class FinlyF.Views.ReportsIndex extends Backbone.View
  templateSkeleton: HandlebarsTemplates['finlyf/base/skeleton']

  #navbar
  templateNavbarSidebar: HandlebarsTemplates['finlyf/reports/navbar/navbar_sidebar']
  templateNavbarMain: HandlebarsTemplates['finlyf/reports/navbar/navbar_main']

  #sidebar
  templateSidebar: HandlebarsTemplates['finlyf/reports/sidebar/sidebar']

  #main
  templateMain: HandlebarsTemplates['finlyf/reports/crud/main']

  events:
    # 'keyup': 'keyMappings'
    'click .navbar-btn-refresh': 'refetchCollection'
    'click .main-select-all:checkbox': 'toggleSelectAll'
    'click .item': 'showDetails'
    'click .close-details': 'closeDetails'
    'click .btn-new': 'new'
    'click .btn-create': 'create'
    'click .load-more': 'loadMore'
    'click .filter-status li a': 'filterStatus'
    'click .navbar-menu-li': 'navigate'
    'click .navbar-view-type': 'changeView'

    'click .btn-reset-filters': 'resetFilters'
    'click .btn-report-export': 'exportReports'
    

    #Filters
    'keyup .filter-field': 'autoComplete'
    'click .btn-filter': 'filter'

  initialize: (options) ->
    if options
      @params = options.params || {}
    else
      @params = {}
    @params.page = 1
    # console.log "Params from view", @params
    # console.log "Step x. Init View"
    _this = @
    @dump = []
    @collection = new FinlyF.Collections.Reports()
    @collection.fetch({
      reset: true,
      data: _this.params,
      success: ->
        _this.toggleLoadMore(_this.collection)
      error: ->
        console.log "Couldn't fetch Successfully."
    })
    @collection.on('reset', @processItems, @)
    @on('item:destroyed', @itemDeleted, @)
    @on('item:selected', @reportsSelectOptions, @)

  render: ->
    $(@el).html(@templateSkeleton())
    $(@el).find(".secondary-navbar .navbar-sidebar").html(@templateNavbarSidebar())
    $(@el).find(".secondary-navbar .navbar-main").html(@templateNavbarMain({item: @params}))
    
    @params.filter_date_from = @params['filter_date[from]']
    @params.filter_date_to = @params['filter_date[to]']
    $(@el).find(".sidebar").html(@templateSidebar({item: @params}))
    $(@el).find(".main").html(@templateMain())
    FinlyF.structureActions(@el, @params)
    @

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
    if collection.models.length < 30
      # console.log "Should hide"
      $(@el).find('.load-more').css('display', 'none')
    else
      $(@el).find('.load-more').css('display', 'inline')

  processItems: ->
    _this = @
    #Append all the reports
    @dump = @collection.models.slice()
    # console.log "Models - ", @collecion.models.length
    $(@el).find("#items").html("")
    # @collection.each(@appendItems, @)
    _.each(_this.collection.models, _this.appendItems, _this)

    #Stop refresh spinner if spinning
    spinner = $(@el).find(".secondary-navbar .navbar-btn-refresh i")
    if $(spinner).hasClass("fa-spin")
      $(spinner).removeClass("fa-spin")
    
    FinlyF.stopMainLoader()

  appendItems: (item) ->
    # console.log "appending"
    #Creating view for each report and appending them
    view_item = new FinlyF.Views.Report({ model: item, parent: @ })
    $(@el).find("#items").append(view_item.render().el)
    # console.log view_item.el

  refetchCollection: (e) ->
    #REFRESH
    #Spin refresh-spinner
    _this = @
    if e
      target = e.currentTarget
      $(target).find("i").addClass("fa-spin")

    @params.page = 1
    @collection.fetch({
      reset: true,
      data: _this.params,
      success: ->
        # console.log _this.collection.models[0].toJSON()
        _this.toggleLoadMore(_this.collection)
        _this.dump.length = 0
        _this.dump = _this.collection.models.slice()
        _this.resetPageCount({selector: '.main .load-more', page: 1})

      error: ->
        console.log "Couldn't fetch successfully."
    })

  toggleSelectAll: (e) ->
    target = e.currentTarget
    items = $(@el).find('#items').find(".item")
    if $(target).prop("checked")
      for item in items
        $(item).addClass("selected")
        $(item).find(".select-item").prop("checked", true)
    else
      for item in items
        $(item).removeClass("selected")
        $(item).find(".select-item").prop("checked", false)
    @reportsSelectOptions()

  showDetails: (e) ->
    if $(e.target).hasClass("select-item")
      return
      
    
    # $(@el).find('#item-details').css('bottom', 0)

    model_id = $(e.currentTarget).find(".select-item").attr('data-item-id')
    model = @collection.get(model_id)

    # preview_view = new FinlyF.Views.Report({
    #   model_id: model.get('id')
    #   preview: true
    #   parent: @
    #   current_view: @params.view || 'personal'
    # })

    # $(@el).find("#item-details-main").html(preview_view.render().el)

    params = {
      view: @params.view || 'personal'
      preview: true
      # parent: @
      # current_view: @params.view || 'personal'
    }

    # console.log model_id, params
    FinlyF.primary_router.navigate('reports/' + model_id.toString() + '/params=' + JSON.stringify(params), {trigger: true})


    

  showReport: (report_id) ->
    #BEING USED FROM ROUTER
    # main = $(@el).find(".main")
    # unless $(main).hasClass("preview")
    #   $(main).addClass("preview")
    
    $(@el).find('#item-details').css('bottom', 0)

    preview_view = new FinlyF.Views.Report({
      model_id: report_id
      preview: true
      parent: @
      current_view: @params.view || 'personal'
    })

    $(@el).find("#item-details-main").html(preview_view.render().el)

  closeDetails: (e)->
    e.preventDefault()
    target = $(e.currentTarget)
    attr = $(target).attr('data-refresh-true')

    if (typeof attr != typeof undefined && attr != false)
      # alert("Data refresh is true")
      # @filter()
      # @collection.reset()

      @refetchCollection()
      $(target).removeAttr('data-refresh-true')
    $(@el).find('#item-details-main').html("")
    $(@el).find('#item-details').css('bottom', '100%') 
    # main = $(@el).find(".main")
    # $(main).removeClass("preview")

  new: ->
    _this = @

    # $(@el).find('#item-details').css('bottom', 0)
    # # main = $(@el).find(".main")
    # # unless $(main).hasClass("preview")
    # #   $(main).addClass("preview")
    # $(@el).find("#item-details-main").html("")

    model = new FinlyF.Models.Report()
    data = {
      authenticity_token: $("#authenticity_token").val()
    }

    params = {
      view: @params.view || 'personal'
      preview: true
    }
    model.save(data, {
      success: (model, res) ->
        # FinlyF.snapNotify(res.messages)
        # preview_view = new FinlyF.Views.Report({
        #   model_id: model.get('id')
        #   preview: true
        #   parent: _this
        #   current_view: _this.params.view || 'personal'
        # })
        # $(_this.el).find("#item-details-main").html(preview_view.render().el)
        # $(_this.el).find('.close-details').attr('data-refresh-true', true)
        FinlyF.primary_router.navigate('reports/' + model.get('id') + '/params=' + JSON.stringify(params), {trigger: true})
      error: (err) ->
        console.log "Error", err
    })

  filterStatus: (e) ->
    # console.log "hit filter"
    e.preventDefault()

    target = $(e.currentTarget)
    # $(target).closest('ul').find('a').removeClass('active')
    $(target).parent().addClass('active')
    # console.log $(target).parent().html()
    status_id = $(target).attr('data-status-id')

    params = {
      'filter_status': status_id
    }
    if @params.view
      params.view = @params.view

    # console.log "will navigate"
    FinlyF.primary_router.navigate('reports/params=' + JSON.stringify(params), {trigger: true})

  reportsSelectOptions: (e) ->
    items = $(@el).find('#items .item.report')
    flag = false
    for item in items
      if $(item).find('.select-item').prop('checked')
        flag = true
    if flag == true
      $(@el).find('.secondary-navbar .btn-export-options').css('display', 'inline')
    else
      $(@el).find('.secondary-navbar .btn-export-options').css('display', 'none')

  resetFilters: ->
    params = {}
    params.view = @params.view
    
    # console.log "will navigate"
    FinlyF.primary_router.navigate('reports/params=' + JSON.stringify(params), {trigger: true})

  filter: ->
    # console.log "Filtering"
    sidebar = $(@el).find(".sidebar")
    params = {
      # 'filter_merchant': $(".sidebar .filter-merchant").val() || ""
      'filter_date[from]': $(".sidebar .filter-date-from").val() || ""
      'filter_date[to]': $(".sidebar .filter-date-to").val() || ""
      'filter_user_id': $(".sidebar .filter-user").attr('data-item-id') || ""
      'filter_user_name': $(".sidebar .filter-user").val() || ""
      'filter_status': @params.filter_status || ""
      # 'filter_category_id': $(".sidebar .filter-category-id").val() || ""
      # 'filter_receipt': $(".sidebar .filter-receipt").val() || ""
    }

    # filter_amount_value = $(".sidebar .filter-amount-value").val()
    # filter_receipt = $(".sidebar .filter-receipt").val()

    # if filter_amount_value
    #   params["filter_amount[value]"] = filter_amount_value
    #   params["filter_amount[type]"] = $(".sidebar .filter-amount-type").val()

    # console.log "Will navigate now."
    if @params.view
      params.view = @params.view

    # console.log "will navigate"
    FinlyF.primary_router.navigate('reports/params=' + JSON.stringify(params), {trigger: true})

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

  itemDeleted: (e) ->
    # console.log "item destoryed"
    _this = @
    # main = $(@el).find(".main")
    # $(main).removeClass("preview")
    $(@el).find('#item-details-main').html("")
    $(@el).find('#item-details').css('bottom', '100%') 

    @params.page = 1
    @collection.fetch({
      data: @params
      reset: true
      success: ->
        _this.toggleLoadMore(_this.collection)
        _this.dump.length = 0
        _this.dump = _this.collection.models.slice()
        _this.resetPageCount({selector: '.main .load-more', page: 1})
    })

  resetPageCount: (options) ->
    if options.target
      $(options.target).attr('data-page', options.page)
    else if options.selector
      $(options.selector).attr('data-page', options.page)
    else
      $('.main .load-more').attr('data-page', options.page)

  navigate: (e) ->
    unless $(e.currentTarget).hasClass('non-backbone-link')
      e.preventDefault()
      FinlyF.navigate(e, @params)
    else
      return

  changeView: (e) ->
    e.preventDefault()
    FinlyF.changeView(e)

  exportReports: (e) ->
    e.preventDefault()
    export_type = $(e.currentTarget).attr('data-export-type')
    items = $(@el).find("#items .item.report")
    reports = []
    for item in items
      selected_item = $(item).find('input.select-item')
      if $(selected_item).prop('checked')
        reports.push($(selected_item).attr('data-item-id'))

    url = "/export/report." + export_type + "?report_id=" + reports.join(",") + "&view=" + (@params.view || 'personal')
    console.log url
    win = window.open(url, '_blank')
    win.focus()

  # keyMappings: (e) ->
  #   console.log "Loggin keys", e.keyCode
