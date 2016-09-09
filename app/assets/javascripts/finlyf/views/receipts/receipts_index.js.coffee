class FinlyF.Views.ReceiptsIndex extends Backbone.View
  templateSkeleton: HandlebarsTemplates['finlyf/base/skeleton']

  #navbar
  templateNavbarSidebar: HandlebarsTemplates['finlyf/receipts/navbar/navbar_sidebar']
  templateNavbarMain: HandlebarsTemplates['finlyf/receipts/navbar/navbar_main']

  #sidebar
  templateSidebar: HandlebarsTemplates['finlyf/receipts/sidebar/sidebar']

  #main
  templateMain: HandlebarsTemplates['finlyf/receipts/crud/index']
  templateNew: HandlebarsTemplates['finlyf/receipts/crud/new']

  #expenses
  templateNewExpense: HandlebarsTemplates['finlyf/expenses/new']

  events:
    'click .navbar-btn-refresh': 'refetchCollection'
    'click .main-select-all:checkbox': 'toggleSelectAll'
    # 'click .item': 'showDetails'
    'click .item': 'selectCurrent'
    'click .close-details': 'closeDetails'
    'click .btn-new': 'new'
    'click .btn-create': 'create'
    'click .load-more': 'loadMore'
    'click .filter-status li a': 'filterStatus'
    'click .navbar-menu-li': 'navigate'
    'click .navbar-view-type': 'changeView'
    'click .btn-reset-filters': 'resetFilters'

    #receipt
    'click .btn-new-expense': 'newExpense'
    'click .btn-create-expense': 'createExpense'

    #Filters
    'keyup .filter-merchant': 'autoComplete'
    'click .btn-filter': 'filter'

  initialize: (options) ->
    if options
      @params = options.params || {}
    else
      @params = {}
    @params.page = 1
    _this = @
    @dump = []
    @collection = new FinlyF.Collections.Receipts()
    @collection.fetch({
      reset: true,
      data: _this.params,
      success: ->

      error: ->
        console.log "Couldn't fetch Successfully."
    })
    @collection.on('reset', @processItems, @)
    @on('item:selected', @receiptSelectOptions, @)

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
    view_item = new FinlyF.Views.Receipt({
      model: item
      parent: @
    })
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
        # _this.dump.length = 0
        # _this.dump = _this.collection.models.slice()
        # _this.resetPageCount({selector: '.main .load-more', page: 1})

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

  selectCurrent: (e) ->
    console.log "hi"
    items = $(@el).find("#items .item")
    for item in items
      $(item).find('.select-item').prop('checked', false)

    $(e.currentTarget).find('.select-item').prop('checked', true)
    @receiptSelectOptions()


    #Returns if clicked on the checkbox
    # if $(e.target).hasClass("select-item")
    #   return
      
    # main = $(@el).find(".main")
    # unless $(main).hasClass("preview")
    #   $(main).addClass("preview")

    # model_id = $(e.currentTarget).find(".select-item").attr('data-item-id')
    # model = @collection.get(model_id)

    # preview_view = new FinlyF.Views.Report({
    #   model: model
    #   preview: true
    # })

    # $(@el).find("#item-details-main").html(preview_view.render().el)
    
  # closeDetails: ->
  #   main = $(@el).find(".main")
  #   $(main).removeClass("preview")

  new: ->
    $("#modal-new .modal-body").html(@templateNew)
    $("#modal-new .modal-body").find("[name=authenticity_token]").val($("#authenticity_token").val())
    $("#modal-new").modal('show')

  create: ->
    values = {};

    # if(event){ event.preventDefault(); }

    _.each($(@el).find('form#new-item').serializeArray(), (input) ->
      values[ input.name ] = input.value
    )
    console.log values
    model = new FinlyF.Models.Receipt()
    # console.log("Putting data")
    console.log(model.save(values, { iframe: true, files: this.$('form :file'), data: values }))






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


  resetFilters: ->
    params = {}
    params.view = @params.view
    FinlyF.primary_router.navigate('receipts/params=' + JSON.stringify(params), {trigger: true})

  filter: ->
    sidebar = $(@el).find(".sidebar")
    params = {
      # 'filter_merchant': $(".sidebar .filter-merchant").val() || ""
      'filter_date[from]': $(".sidebar .filter-date-from").val() || ""
      'filter_date[to]': $(".sidebar .filter-date-to").val() || ""
      # 'filter_category_id': $(".sidebar .filter-category-id").val() || ""
      # 'filter_receipt': $(".sidebar .filter-receipt").val() || ""
    }


    FinlyF.primary_router.navigate('receipts/params=' + JSON.stringify(params), {trigger: true})

  # autoComplete: (e) ->
  #   target = $(e.currentTarget)
  #   query = $(target).val()

  #   $(target).autocomplete({
  #     minLength: 2,
  #     source: (request, response) ->
  #       $.ajax({
  #         dataType: "json"
  #         type : 'get'
  #         url: '/autocomplete/merchant'
  #         data: 
  #           remote: "true"
  #           query: query
  #           # area: 'central'
  #         success: (data) ->
  #           response(data)
  #         error: (err) ->
  #           console.log err
  #       })
  #     select: (event, ui) ->
  #       console.log "Selected."
  #   })

  # resetPageCount: (options) ->
  #   if options.target
  #     $(options.target).attr('data-page', options.page)
  #   else if options.selector
  #     $(options.selector).attr('data-page', options.page)
  #   else
  #     $('.main .load-more').attr('data-page', options.page)



  navigate: (e) ->
    e.preventDefault()
    FinlyF.navigate(e, @params)


  changeView: (e) ->
    e.preventDefault()
    FinlyF.changeView(e)

  receiptSelectOptions: ->
    console.log "receipt"
    items = $(@el).find('#items .item')
    flag = false
    for item in items
      if $(item).find('.select-item').prop('checked')
        flag = true
    if flag == true
      $(@el).find('.secondary-navbar .btn-new-expense').css('display', 'inline')
    else
      $(@el).find('.secondary-navbar .btn-new-expense').css('display', 'none')

  newExpense: ->
    console.log 'hey'
    items = $(@el).find("#items .item")
    console.log items.length
     # "report"=>{"expense_id"=>"15,36,39"}}
    # items = $(@el).find('#items .item')
    # receipt= []
    # flag = false
    for item in items
      selected_item = $(item).find('.select-item')
      if $(selected_item).prop('checked')
        # receipt = 
        receipt_id = $(selected_item).attr('data-item-id')
        break
    
    selected_receipt = @collection.get(parseInt(receipt_id))

    $("#modal-new .modal-body").html(@templateNewExpense({receipt: {id: selected_receipt.get('id')}}))
    $("#modal-new .modal-body").find("[name=authenticity_token]").val($("#authenticity_token").val())

    category_select = $("#modal-new .modal-body").find(".newExpenseCategory")
    options = $("#newExpenseCategory option")
    for option in options
      $('<option/>', {
        value: $(option).attr('value')
        text: $(option).text()
      }).appendTo(category_select)
    $("#modal-new").modal('show')

    # console.log selected_receipt.toJSON()

    $("#modal-new .modal-body #preview-image").attr('src', selected_receipt.get('url'))


  createExpense: (e) ->
    _this =   @
    values = {}

    # if(event){ event.preventDefault(); }

    _.each($("#modal-new form#new-item").serializeArray(), (input) ->
      values[ input.name ] = input.value
    )
    console.log values
    model = new FinlyF.Models.Expense()
    # console.log("Putting data")
    response = model.save(values, {
      iframe: true,
      files: this.$('form :file'),
      # data: values
      processData: true
      success: (model, res) ->
        $("#modal-new").modal('hide')
        # _this.model.fetch({
        #   data: _this.current_view
        # })
      error: (err) ->
        console.log "Error", err
    })

    console.log response

    # # console.log expenses
    # model_report = new FinlyF.Models.Report({
    #   "report": {
    #     "expense_id": expenses.join(","),
    #   },
    #   "authenticity_token": $("#authenticity_token").val()
    #   "utf8": $("#form_utf8").val()
    # })
    # # console.log "Model", model_report.toJSON()
    # model_report.save(null, {
    #   success: (model, res) ->
    #     if res.status == "success"
    #       FinlyF.primary_router.navigate('reports', {trigger: true})
    #   error: (err) ->
    #     console.log "Error", err
    # })
