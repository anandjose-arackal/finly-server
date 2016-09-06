class FinlyF.Views.ReportsIndex extends Backbone.View
  templateSkeleton: HandlebarsTemplates['finlyf/base/skeleton']

  #navbar
  templateNavbarSidebar: HandlebarsTemplates['finlyf/reports/navbar/navbar_sidebar']
  templateNavbarMain: HandlebarsTemplates['finlyf/reports/navbar/navbar_main']

  #sidebar
  templateSidebar: HandlebarsTemplates['finlyf/reports/sidebar/sidebar']

  #main
  templateMain: HandlebarsTemplates['finlyf/reports/crud/main']
  templateNew: HandlebarsTemplates['finlyf/reports/crud/new']

  events:
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
    

    #Filters
    'keyup .filter-field': 'autoComplete'
    'click .btn-filter': 'filter'

  initialize: (options) ->
    if options
      @params = options.params || {}
    else
      @params = {}
    @params.page = 1
    console.log "Params from view", @params
    # console.log "Step x. Init View"
    _this = @
    @dump = []
    @collection = new FinlyF.Collections.Reports()
    @collection.fetch({
      reset: true,
      data: _this.params,
      success: ->

      error: ->
        console.log "Couldn't fetch Successfully."
    })
    @collection.on('reset', @processItems, @)
    @on('item:destroyed', @filter, @)

  render: ->
    # console.log "Step 3. Rendering."
    #Appending Partials to Skeleton

    $(@el).html(@templateSkeleton())
    $(@el).find(".secondary-navbar .navbar-sidebar").html(@templateNavbarSidebar())
    $(@el).find(".secondary-navbar .navbar-main").html(@templateNavbarMain())

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
        $(target).find('i').addClass('fa-cloud-download').removeClass('fa-spinner fa-pulse')
        $(target).find('span').text('Load More')
        _this.resetPageCount({target: target, page: _this.params.page })

        _this.dump = (_this.dump.concat(_this.collection.models.slice())).slice()

        _this.collection.reset(_this.dump)

      error: ->
        console.log "Couldn't fetch Successfully."
    })

  processItems: ->
    #Append all the reports
    @dump = @collection.models.slice()
    # console.log "Models - ", @collection.models.length
    $(@el).find("#items").html("")
    @collection.each(@appendItems, @)

    #Stop refresh spinner if spinning
    spinner = $(@el).find(".secondary-navbar .navbar-btn-refresh i")
    if $(spinner).hasClass("fa-spin")
      $(spinner).removeClass("fa-spin")

  appendItems: (item) ->
    #Creating view for each report and appending them
    view_item = new FinlyF.Views.Report({ model: item })
    $(@el).find("#items").append(view_item.render().el)

  refetchCollection: (e) ->
    #REFRESH
    #Spin refresh-spinner
    _this = @
    target = e.currentTarget
    $(target).find("i").addClass("fa-spin")

    @params.page = 1
    @collection.fetch({
      reset: true,
      data: _this.params,
      success: ->
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

  showDetails: (e) ->
    # bd = $("<div />", {
    #   class: "finly-backdrop"
    # }).appendTo('.main')
    #Returns if clicked on the checkbox
    if $(e.target).hasClass("select-item")
      return
      
    main = $(@el).find(".main")
    unless $(main).hasClass("preview")
      $(main).addClass("preview")

    model_id = $(e.currentTarget).find(".select-item").attr('data-item-id')
    model = @collection.get(model_id)

    preview_view = new FinlyF.Views.Report({
      model: model
      preview: true
      parent: @
      current_view: @params.view || 'personal'
    })

    $(@el).find("#item-details-main").html(preview_view.render().el)

  # createReport: ->


    
  closeDetails: (e) ->
    e.preventDefault()
    target = $(e.currentTarget)
    if $(target).attr('data-refresh-true')
      # alert("Data refresh is true")
      # @filter()
      @refetchCollection()
      $(target).removeAttr('data-refresh-true')
    main = $(@el).find(".main")
    $(main).removeClass("preview")

  new: ->
    _this = @
    main = $(@el).find(".main")
    unless $(main).hasClass("preview")
      $(main).addClass("preview")
    $(@el).find("#item-details-main").html("")

    model = new FinlyF.Models.Report()
    data = {
      authenticity_token: $("#authenticity_token").val()
    }
    model.save(data, {
      success: (model, res) ->
        preview_view = new FinlyF.Views.Report({
          model: model
          preview: true
          parent: _this
        })
        $(_this.el).find("#item-details-main").html(preview_view.render().el)
        $(_this.el).find('.close-details').attr('data-refresh-true', true)
      error: (err) ->
        console.log "Error", err
    })


  # create: ->
  #   values = {};
  #   # if(event){ event.preventDefault(); }
  #   _.each($(@el).find('form#new-item').serializeArray(), (input) ->
  #     values[ input.name ] = input.value
  #   )
  #   console.log values
  #   model = new FinlyF.Models.Report()
  #   console.log("Putting data")
  #   console.log(model.save(values, { iframe: true, files: this.$('form :file'), data: values }))



    # _this = @
    # form = $(@el).find('#new-report')
    # data = {
    #   amount: $(form).find('input[name="report[amount]"]').val()
    #   merchant: $(form).find('input[name="report[merchant]"]').val()
    #   date: $(form).find('input[name="report[date]"]').val()
    #   category_id: $(form).find('select[name="report[category_id]"]').val()
    # }

    # model = new FinlyF.Models.report(data)
    # console.log model.toJSON()
    # model.save({
    #   success: ->
    #     @collection.fetch({reset: true})
    # })

  


  filterStatus: (e) ->
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

    FinlyF.primary_router.navigate('reports/params=' + JSON.stringify(params), {trigger: true})

  resetFilters: ->
    params = {}
    params.view = @params.view
    FinlyF.primary_router.navigate('reports/params=' + JSON.stringify(params), {trigger: true})

  filter: ->
    # console.log "Filtering"
    sidebar = $(@el).find(".sidebar")
    params = {
      # 'filter_merchant': $(".sidebar .filter-merchant").val() || ""
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

    FinlyF.primary_router.navigate('reports/params=' + JSON.stringify(params), {trigger: true})

  autoComplete: (e) ->
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
            remote: "true"
            query: query
          success: (data) ->
            response(data)
          error: (err) ->
            console.log err
        })

      focus: (event, ui) ->
        $(event.target).val(ui.item.label)
        $(event.target).attr('data-id', ui.item.value)
        return false

      select: (event, ui) ->
        $(event.target).val(ui.item.label)
        $(event.target).attr('data-id', ui.item.value)
        return false

    })

  resetPageCount: (options) ->
    if options.target
      $(options.target).attr('data-page', options.page)
    else if options.selector
      $(options.selector).attr('data-page', options.page)
    else
      $('.main .load-more').attr('data-page', options.page)

  navigate: (e) ->
    e.preventDefault()
    FinlyF.navigate(e, @params)


  changeView: (e) ->
    e.preventDefault()
    FinlyF.changeView(e)