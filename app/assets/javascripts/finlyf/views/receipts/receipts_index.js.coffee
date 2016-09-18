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
    # 'click .btn-create': 'create'
    'submit form#new-item': 'create'
    'click .load-more': 'loadMore'
    'click .filter-status li a': 'filterStatus'
    'click .navbar-menu-li': 'navigate'
    'click .navbar-view-type': 'changeView'
    'click .btn-reset-filters': 'resetFilters'

    #receipt
    'click .btn-new-expense': 'newExpense'
    'click .btn-create-expense': 'createExpense'
    'click .btn-delete-receipt': 'delete'
    # 'click .btn-delete-receipt': 'delete'

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
    # if $(e.currentTarget).hasClass('fa-trash')
    #   @delete(e)
    #   return
    # console.log "hi"
    items = $(@el).find("#items .item")
    for item in items
      $(item).find('.select-item').prop('checked', false)
      $(item).removeClass('selected')

    $(e.currentTarget).find('.select-item').prop('checked', true)
    $(e.currentTarget).closest('.item').addClass('selected')
    @receiptSelectOptions()

  new: ->
    $("#modal-new .modal-body").html(@templateNew)
    $("#modal-new .modal-body").find("[name=authenticity_token]").val($("#authenticity_token").val())
    $("#modal-new").attr('data-backdrop', false)
    $("#modal-new").modal('show')

  create: (e)->
    _this = @
    e.preventDefault()
    formData = new FormData(e.currentTarget)

    $.ajax({
      url: '/receipts'
      type: 'POST',
      data: formData,
      async: true,
      success: (res) ->
        # console.log(data)
        if res.success == true
          FinlyF.snapNotify(res.messages)
          $("#modal-new").modal('hide')
          _this.filter()
      error: (err) ->
        console.log "Err", err
      cache: false,
      contentType: false,
      processData: false
    })


    # _.each($(@el).find('form#new-item').serializeArray(), (input) ->
    #   values[ input.name ] = input.value
    # )
    # # console.log values
    # model = new FinlyF.Models.Receipt()
    # # console.log("Putting data")
    # response = model.save(values,{
    #   iframe: true,
    #   files: this.$('form :file'),
    #   data: values
    #   success: (model, res) ->
    #     console.log "Success", model, res
    #     $("#modal-new").modal('hide')
    #     _this.filter()
    #   error: (err, model) ->
    #     console.log "Err", err, model
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

  navigate: (e) ->
    unless $(e.currentTarget).hasClass('non-backbone-link')
      e.preventDefault()
      FinlyF.navigate(e, @params)
    else
      return

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
      $(@el).find('.secondary-navbar .btn-delete-receipt').css('display', 'inline')
      $(@el).find('.secondary-navbar .btn-new-expense').css('display', 'inline')
    else
      $(@el).find('.secondary-navbar .btn-delete-receipt').css('display', 'none')
      $(@el).find('.secondary-navbar .btn-new-expense').css('display', 'none')

  newExpense: ->
    # console.log 'hey'
    items = $(@el).find("#items .item")
    # console.log items.length
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
    $("#modal-new").attr('data-backdrop', false)
    $("#modal-new").modal('show')
    $("#modal-new").find(".datepicker").datepicker({dateFormat: "yy-mm-dd"})

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
      # files: this.$('form :file'),
      data: values
      processData: true
      success: (model, res) ->
        FinlyF.snapNotify(res.messages)
        # console.log "Success", model, res
        $(_this.el).find("#modal-new").modal('hide')
        _this.filter()
      error: (err) ->
        console.log "Error", err
    })

  delete: (e) ->
    items = $(@el).find("#items .item")
    for item in items
      selected_item = $(item).find('.select-item')
      if $(selected_item).prop('checked')
        receipt_id = $(selected_item).attr('data-item-id')
        break
    
    selected_receipt = @collection.get(parseInt(receipt_id))

    selected_receipt.destroy({
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        console.log "deleted", res
    })