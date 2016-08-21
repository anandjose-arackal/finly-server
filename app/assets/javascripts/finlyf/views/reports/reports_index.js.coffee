class FinlyF.Views.ReportsIndex extends Backbone.View
  templateSkeleton: HandlebarsTemplates['finlyf/base/skeleton']

  #navbar
  templateNavbarSidebar: HandlebarsTemplates['finlyf/expenses/navbar/navbar_sidebar']
  templateNavbarMain: HandlebarsTemplates['finlyf/expenses/navbar/navbar_main']

  #sidebar
  templateSidebar: HandlebarsTemplates['finlyf/expenses/sidebar/sidebar']

  #main
  templateMain: HandlebarsTemplates['finlyf/reports/crud/main']
  templateNew: HandlebarsTemplates['finlyf/expenses/new']

  events:
    'click .navbar-btn-refresh': 'refetchCollection'
    'click .main-select-all:checkbox': 'toggleSelectAll'
    'click .expense': 'showDetails'
    'click .close-details': 'closeDetails'
    'click .btn-new': 'new'
    'click .btn-create': 'create'
    'click .load-more': 'loadMore'

    #Filters
    'keyup .filter-merchant': 'autoComplete'
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

      error: ->
        console.log "Couldn't fetch Successfully."
    })
    @collection.on('reset', @processItems, @)

  render: ->
    # console.log "Step 3. Rendering."
    #Appending Partials to Skeleton

    $(@el).html(@templateSkeleton())
    $(@el).find(".secondary-navbar .navbar-sidebar").html(@templateNavbarSidebar())
    $(@el).find(".secondary-navbar .navbar-main").html(@templateNavbarMain())
    $(@el).find(".sidebar").html(@templateSidebar())
    $(@el).find(".main").html(@templateMain())
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
    #Append all the expenses
    @dump = @collection.models.slice()
    console.log "Models - ", @collection.models.length
    $(@el).find("#expenses").html("")
    @collection.each(@appendItems, @)

    #Stop refresh spinner if spinning
    spinner = $(@el).find(".secondary-navbar .navbar-btn-refresh i")
    if $(spinner).hasClass("fa-spin")
      $(spinner).removeClass("fa-spin")

  appendItems: (item) ->
    #Creating view for each expense and appending them
    view_item = new FinlyF.Views.Expense({ model: item })
    $(@el).find("#expenses").append(view_item.render().el)

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
    items = $(@el).find('#expenses').find(".expense")
    if $(target).prop("checked")
      for item in items
        $(item).addClass("selected")
        $(item).find(".select-item").prop("checked", true)
    else
      for item in items
        $(item).removeClass("selected")
        $(item).find(".select-item").prop("checked", false)

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
      model: model
      preview: true
    })

    $(@el).find("#item-details-main").html(preview_view.render().el)
    
  closeDetails: ->
    main = $(@el).find(".main")
    $(main).removeClass("preview")

  new: ->
    $("#modal-new .modal-body").html(@templateNew)
    $("#modal-new .modal-body").find("[name=authenticity_token]").val($("#authenticity_token").val())
    $("#modal-new").modal('show')

  create: ->
    values = {};

    # if(event){ event.preventDefault(); }

    _.each($(@el).find('form#new-expense').serializeArray(), (input) ->
      values[ input.name ] = input.value
    )
    console.log values
    model = new FinlyF.Models.Expense()
    console.log("Putting data")
    console.log(model.save(values, { iframe: true, files: this.$('form :file'), data: values }))






    # _this = @
    # form = $(@el).find('#new-expense')
    # data = {
    #   amount: $(form).find('input[name="expense[amount]"]').val()
    #   merchant: $(form).find('input[name="expense[merchant]"]').val()
    #   date: $(form).find('input[name="expense[date]"]').val()
    #   category_id: $(form).find('select[name="expense[category_id]"]').val()
    # }

    # model = new FinlyF.Models.Expense(data)
    # console.log model.toJSON()
    # model.save({
    #   success: ->
    #     @collection.fetch({reset: true})
    # })

  filter: ->
    sidebar = $(@el).find(".sidebar")
    params = {
      # manual_expense_id: 2
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

    FinlyF.primary_router.navigate('expenses/' + JSON.stringify(params), {trigger: true})

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

  resetPageCount: (options) ->
    if options.target
      $(options.target).attr('data-page', options.page)
    else if options.selector
      $(options.selector).attr('data-page', options.page)
    else
      $('.main .load-more').attr('data-page', options.page)
