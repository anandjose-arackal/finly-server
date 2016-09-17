class FinlyF.Views.ExpensesIndex extends Backbone.View
  templateSkeleton: HandlebarsTemplates['finlyf/base/skeleton']
  templateSkeletonIndexOnly: HandlebarsTemplates['finlyf/base/skeletonIndexOnly']

  #navbar
  templateNavbarSidebar: HandlebarsTemplates['finlyf/expenses/navbar/navbar_sidebar']
  templateNavbarMain: HandlebarsTemplates['finlyf/expenses/navbar/navbar_main']

  #sidebar
  templateSidebar: HandlebarsTemplates['finlyf/expenses/sidebar/sidebar']
  templateSidebarIndexOnly: HandlebarsTemplates['finlyf/expenses/sidebar/sidebarIndexOnly']


  #main
  templateMain: HandlebarsTemplates['finlyf/expenses/crud/main']
  templateNewExpense: HandlebarsTemplates['finlyf/expenses/new']

  #IO (IndexOnly)
  templateIOSkeleton: HandlebarsTemplates['finlyf/base/skeletonIO']

  events:
    'click .navbar-btn-refresh': 'refetchCollection'
    'click .main-select-all:checkbox': 'toggleSelectAll'
    'click .item': 'showDetails'
    'click .close-details': 'closeDetails'
    'click .btn-new': 'new'
    'click .btn-create-report': 'createReport'
    'click .btn-create-expense': 'create'
    'click .load-more': 'loadMore'
    'click .navbar-menu-li': 'navigate'
    'click .navbar-view-type': 'changeView'
    'submit .navbar-form': 'globalSearch'
    'click .input-search-icon': 'clearGlobalSearch'
    'click .btn-reset-filters': 'resetFilters'
    #Filters
    'keyup .filter-merchant': 'autoComplete'
    'click .btn-filter-expenses': 'filter'

  initialize: (options) ->
    if Backbone.history.getFragment() == ""
      FinlyF.primary_router.navigate("expenses")
    if options

      @params = options.params || {}
      if options.indexOnly
        @indexOnly = true
      if options.parent
        @parent = options.parent
    else
      @params = {}
    @params.page = 1
    # console.log "Params from view", @params
    # console.log "Step x. Init View"
    _this = @
    @dump = []
    @collection = new FinlyF.Collections.Expenses()
    @collection.fetch({
      reset: true,
      data: _this.params,
      success: ->

      error: ->
        console.log "Couldn't fetch Successfully."
    })
    @collection.on('reset', @processItems, @)
    @on('item:selected', @expenseSelectOptions, @)
    @on('item:destroyed', @itemDeleted, @)

  render: ->
    # console.log "Step 3. Rendering."
    #Appending Partials to Skeleton
    unless @indexOnly
      $(@el).html(@templateSkeleton())
      $(@el).find(".secondary-navbar .navbar-sidebar").html(@templateNavbarSidebar())

      $(@el).find(".secondary-navbar .navbar-main").html(@templateNavbarMain({item: @params}))

      @params.filter_date_from = @params['filter_date[from]']
      @params.filter_date_to = @params['filter_date[to]']
      @params.filter_amount_value = @params['filter_amount[value]']
      @params.filter_amount_type = @params['filter_amount[type]']
      @params.indexOnly = false#REF==2I


      $(@el).find(".sidebar").html(@templateSidebar({item: @params}))
      category_select = $(@el).find(".filter-category-id")
      options = $("#newExpenseCategory option")
      for option in options
        $('<option/>', {
          value: $(option).attr('value')
          text: $(option).text()
        }).appendTo(category_select)
      $(@el).find(".main").html(@templateMain({ item: {indexOnly: false }}))#REF==1I
      FinlyF.structureActions(@el, @params)
    else
      $(@el).html(@templateSkeletonIndexOnly())
      $(@el).find('.sidebar').html(@templateSidebar({item: {indexOnly: true}}))#REF==2I
      category_select = $(@el).find(".filter-category-id")
      options = $("#newExpenseCategory option")
      for option in options
        $('<option/>', {
          value: $(option).attr('value')
          text: $(option).text()
        }).appendTo(category_select)
      $(@el).find('.main').html(@templateMain({ item: {indexOnly: true }}))#REF==1I
    @

  processItems: ->
    #Append all the expenses
    @dump = @collection.models.slice()
    # console.log "Models - ", @collection.models.length
    $(@el).find("#items").html("")
    @collection.each(@appendItems, @)

    #Stop refresh spinner if spinning
    spinner = $(@el).find(".secondary-navbar .navbar-btn-refresh i")
    if $(spinner).hasClass("fa-spin")
      $(spinner).removeClass("fa-spin")

  appendItems: (item) ->
    #Creating view for each expense and appending them
    view_item = new FinlyF.Views.Expense({
      model: item
      parent: @
    })
    $(@el).find("#items").append(view_item.render().el)

  refetchCollection: (e) ->
    #REFRESH
    #Spin refresh-spinner
    # console.log "Hi"
    _this = @

    main = $(@el).find(".main")
    $(main).removeClass("preview")

    if e
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

    @expenseSelectOptions()

  showDetails: (e) ->
    #Returns if clicked on the checkbox
    if $(e.target).hasClass("select-item")
      return
      
    main = $(@el).find(".main")
    unless $(main).hasClass("preview")
      $(main).addClass("preview")

    model_id = $(e.currentTarget).find(".select-item").attr('data-item-id')
    model = @collection.get(model_id)

    preview_view = new FinlyF.Views.Expense({
      model_id: model.get('id')
      preview: true
      parent: @
    })

    $(@el).find("#item-details-main").html(preview_view.render().el)

  closeDetails: (e)->
    if e
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
    $("#modal-new .modal-body").html(@templateNewExpense)
    $("#modal-new .modal-body").find("[name=authenticity_token]").val($("#authenticity_token").val())

    #Populate categories from index.json.jbuilder  
    category_select = $("#modal-new .modal-body").find(".newExpenseCategory")
    options = $("#newExpenseCategory option")
    for option in options
      $('<option/>', {
        value: $(option).attr('value')
        text: $(option).text()
      }).appendTo(category_select) 
    
    $("#modal-new").modal('show')
    $("#modal-new").find(".datepicker").datepicker({dateFormat: "yy-mm-dd"})

  create: (e)->
    _this = @
    e.preventDefault()
    formData = new FormData($(@el).find('form#new-item')[0])

    $.ajax({
      url: '/expenses'
      type: "POST",
      data: formData,
      success: (res) ->
        console.log res.messages
        FinlyF.snapNotify(res.messages)
        if res.success == true
          $("#modal-new").modal('hide')
          _this.refetchCollection()
      error: (err) ->
        console.log "Error", err 
      cache: false,
      contentType: false,
      processData: false
    })



    # values = {}

    # # if(event){ event.preventDefault(); }

    # _.each($(@el).find('form#new-item').serializeArray(), (input) ->
    #   values[ input.name ] = input.value
    # )
    # # console.log values
    # model = new FinlyF.Models.Expense()
    # # console.log("Putting data")
    # response = model.save(values, {
    #   iframe: true,
    #   files: this.$('form :file'),
    #   data: values,
    #   success: (model, res) ->
    #     FinlyF.snapNotify(res.messages)
    #     if res.status == "success"
    #       $("#modal-new").modal('hide')
    #       _this.refetchCollection()
    #   error: (err) ->
    #     console.log "Error", err

    # })

    # console.log "Response", response

    # if response.responseJSON.status = "success"

  createReport: ->
    #  "report"=>{"expense_id"=>"15,36,39"}}
    items = $(@el).find('#items .item')
    expenses = []
    flag = false
    for item in items
      selected_item = $(item).find('.select-item')
      if $(selected_item).prop('checked')
        expenses.push($(selected_item).attr('data-item-id'))

    # console.log expenses
    model_report = new FinlyF.Models.Report({
      "expense_ids": expenses.join(","),
      # "expense_ids": expenses,
      "authenticity_token": $("#authenticity_token").val()
      "utf8": $("#form_utf8").val()
    })
    # console.log "Model", model_report.toJSON()
    model_report.save(null, {
      success: (model, res) ->
        if res.success == true
          FinlyF.snapNotify(res.messages)
          FinlyF.primary_router.navigate('reports', {trigger: true})
      error: (err) ->
        console.log "Error", err
    })

  expenseSelectOptions: ->
    unless @parent
      items = $(@el).find('#items .item')
      flag = false
      for item in items
        if $(item).find('.select-item').prop('checked')
          flag = true
      if flag == true
        $(@el).find('.secondary-navbar .btn-create-report').css('display', 'inline')
      else
        $(@el).find('.secondary-navbar .btn-create-report').css('display', 'none')
    else#unless
      @parent.trigger('expense:selected')#REF==3I

  resetFilters: ->
    params = {}
    params.view = @params.view
    FinlyF.primary_router.navigate('expenses/params=' + JSON.stringify(params), {trigger: true})

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
        FinlyF.primary_router.navigate('expenses/params=' + JSON.stringify(params), {trigger: true})  
      else
        #Navigates by refetching & resetting collection with params
        @collection.fetch({
          reset: true,
          data: params,
          success: ->
            console.log "Fetched all the data"
          error: ->
            console.log "Couldn't fetch Successfully."
        })

  globalSearch: (e) ->
    e.preventDefault()
    target = $(e.currentTarget)
    query = $(target).find(".input-global-search").val()
    params = {
      filter_search: query
    }

    if @params.view
      params.view = @params.view

    FinlyF.primary_router.navigate('expenses/params=' + JSON.stringify(params), {trigger: true})

  clearGlobalSearch: (e) ->
    e.preventDefault()
    # target = $(e.currentTarget)
    # query = $(target).find(".input-global-search").val()
    params = {}

    if @params.view
      params.view = @params.view

    FinlyF.primary_router.navigate('expenses/params=' + JSON.stringify(params), {trigger: true})

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
        console.log "Selected."
    })

  itemDeleted: (e) ->
    _this = @
    main = $(@el).find(".main")
    $(main).removeClass("preview")

    @params.page = 1
    @collection.fetch({
      data: @params
      reset: true
      success: ->
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