class FinlyF.Views.SettlementsIndex extends Backbone.View
  templateSkeleton: HandlebarsTemplates['finlyf/settlements/skeleton']
  templateSkeletonAdmin: HandlebarsTemplates['finlyf/settlements/skeletonAdmin']

  #sidebar
  templateSidebarAdmin: HandlebarsTemplates['finlyf/settlements/sidebar/sidebar_admin']

  #main

  templateSummary: HandlebarsTemplates['finlyf/settlements/summary']
  templateSummaryAdmin: HandlebarsTemplates['finlyf/settlements/summaryAdmin']
  templateMain: HandlebarsTemplates['finlyf/settlements/crud/index']
  templateMainPayments: HandlebarsTemplates['finlyf/settlements/crud/indexPayments']

  #settlements
  templateAddPayment: HandlebarsTemplates['finlyf/settlements/admin/addPayment']
  templateSettleDebts: HandlebarsTemplates['finlyf/settlements/admin/settleDebts']
  templateReimburse: HandlebarsTemplates['finlyf/settlements/admin/reimburse']
  templateMoneyRequest: HandlebarsTemplates['finlyf/settlements/admin/moneyRequest']

  events:
    'click .navbar-btn-refresh': 'refetchCollection'
    'click .item': 'showDetails'
    'click .load-more': 'loadMore'
    'click .filter-status li a': 'filterStatus'

    'click .navbar-menu-li': 'navigate'
    'click .navbar-view-type': 'changeView'

    #Filters
    'click .btn-filter': 'filter'
    'click .user': 'userSettlements'

    'click .btn-process-reimburse': 'initReimburse'
    'click .btn-process-debt': 'initDebt'
    'click .btn-process-payment': 'initPayment'
    'click .btn-process-money-request': 'initCreditMoneyRequest'

    #settlements
    'click .btn-cancel-confirmation': 'cancelConfirmation'
    'click .btn-add-payment': 'addPayment'
    # 'click .settlement-report': 'processSettlementReport'
    'click .settlement-report-select:checkbox': 'processSettlementReport'
    'click .btn-settlement-action': 'processSettlementAction'
    'click .confirm-report-action': 'confirmReportAction'
    'keyup .search-user': 'prepareSearch'
    'submit .navbar-form': 'cancelEvents'

  initialize: (options) ->
    # console.log options
    _this = @
    @collectionUsers = new FinlyF.Collections.Users()
    @collectionUsers.url = "/settlements"
    @collection = new FinlyF.Collections.Settlements()
    @collectionSettlementReports = new FinlyF.Collections.Settlements()
    if options.params
      @params = options.params
      if options.params.view == 'personal' || typeof options.params.view == 'undefined'
        @view = 'personal'
        @user = options.user
        @params.id = @user

        unless @params.view_to_load
          @params.view_to_load = 'approved'
        
        @collection.url = @collection.url + "/" + @user.toString()
        @collection.fetch({
          reset: true,
          data: _this.params
          success: ->
            _this.populateSummary()

          error: ->
            console.log "Couldn't fetch Successfully."
        })
      else
        @selected = []
        @selectedReports = []
        console.log "params for admin is", @params
        # @params = options.params || {}
        
        @collectionUsers.fetch({
          reset: true,
          data: @params,
          success: (res)->
            console.log res
        })
        @params = options.params
        
    @dump = []

    
    @collection.on('reset', @processItems, @)
    @collectionUsers.on('reset', @processUsers, @)

  render: ->
    # console.log "Step 3. Rendering."
    #Appending Partials to Skeleton
    if @view == 'personal'
      # if @params.view == 'personal'
      $(@el).html(@templateSkeleton({item: @params}))
      if @params
        if @params.view_to_load == "payments"
          $(@el).find(".settlements-index").html(@templateMainPayments())
        else
          $(@el).find(".settlements-index").html(@templateMain())
      else
        $(@el).find(".settlements-index").html(@templateMainPayments())
    else
      $(@el).html(@templateSkeletonAdmin({item: @params}))
      $(@el).find('.filter-status li a[data-view=payments]').parent().addClass('active')
      $(@el).find(".settlements-index").html(@templateMainPayments())

    # $(@el).find(".secondary-navbar .navbar-sidebar").html(@templateNavbarSidebar())
    # $(@el).find(".secondary-navbar .navbar-main").html(@templateNavbarMain())
    # $(@el).find(".sidebar").html(@templateSidebar())
    
    
    FinlyF.structureActions(@el, @params)

    # Populate summary
    # @populateSummary()
    # console.log "Rendering"
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

  populateSummary: (id)->
    user_id = id || @user
    # console.log "populating"
    _this = @
    $.ajax({
      url: '/settlements/summary?id=' + user_id.toString(),
      dataType: 'json',
      data: {
        view_to_load: @params.view_to_load
        view: @params.view
        authenticity_token: $("#authenticity_token").val()
      },
      success: (res) ->
        # console.log "res", res
        if _this.view == 'personal'
          $(_this.el).find(".summary").html(_this.templateSummary({item: res}))
        else
          $(_this.el).find(".summary").html(_this.templateSummaryAdmin({item: res}))
      error: (err) ->
        console.log err

    })

  processUsers: ->
    console.log "processing users"
    @dump = @collectionUsers.models.slice()
    $(@el).find("#users").html("")

    @collectionUsers.each(@appendUsers, @)

  appendUsers: (user) ->
    console.log "appending users"
    view_user = new FinlyF.Views.User({model: user, page: 'settlements'})
    $(@el).find("#users").append(view_user.render().el)

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
    view_item = new FinlyF.Views.Settlement({ model: item })
    $(@el).find("#items").append(view_item.render().el)

  refetchCollection: (e) ->
    #REFRESH
    #Spin refresh-spinner
    _this = @
    target = e.currentTarget
    $(target).find("i").addClass("fa-spin")

    # @params.page = 1
    @collection.fetch({
      reset: true,
      # data: _this.params,
      success: ->
        _this.dump.length = 0
        _this.dump = _this.collection.models.slice()
        _this.resetPageCount({selector: '.main .load-more', page: 1})

      error: ->
        console.log "Couldn't fetch successfully."
    })

  filterStatus: (e) ->
    _this = @
    e.preventDefault()
    target = $(e.currentTarget)
    view_to_load = $(target).attr('data-view')
    user_id = $(target).attr('data-item-id')

    params = {
      # 'filter_status': status_id
      'view_to_load': view_to_load
    }
    if @view == 'personal'
      FinlyF.primary_router.navigate(@collection.url + '/params=' + JSON.stringify(params), {trigger: true})
    else
      $(target).parent().siblings('li').removeClass('active')
      $(target).parent().addClass('active')
      if view_to_load == 'payments'
        $(@el).find(".settlements-index").html(@templateMainPayments())
      else
        $(@el).find(".settlements-index").html(@templateMain())
      # console.log @collection.url
      @params.view_to_load = view_to_load
      @collection.fetch({
        data: @params
        reset: true,
        # data: _this.params
        success: ->
          _this.populateSummary(_this.user_id)

        error: ->
          console.log "Couldn't fetch Successfully."
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

  prepareSearch: (e) ->
    # console.log _.debounce(@searchUser(e), 500, true)
    if $(e.currentTarget).val().length > 2 || $(e.currentTarget).val().length == 0
      @searchUser(e)

  searchUser: (e) ->
    query = $(e.currentTarget).val()
    @collectionUsers.fetch({
      reset: true,
      data: {
        view: @params.view
        filter_search: query
      }
    }) 

    # console.log query

  cancelEvents: (e) ->
    e.preventDefault()

  userSettlements: (e) ->
    $(@el).find('.settlements-content').css('display', 'block')
    #Load settlement for the user
    target = e.currentTarget
    $(target).siblings().removeClass("active")
    $(target).addClass("active")

    _this = @
    user_id = $(target).find(".user-name").attr("data-item-id")
    @user_id = user_id
    # console.log "User id is", user_id
    # console.log @collection.url
    if typeof @params.view == 'undefined'
      @params.view = 'personal'
    if typeof @params.view_to_load == 'undefined'
      @params.view_to_load = 'payments'
    @collection.url = "/settlements/" + user_id.toString()
    @collection.fetch({
      reset: true,
      data: _this.params
      success: ->
        _this.populateSummary(user_id)

      error: ->
        console.log "Couldn't fetch Successfully."
    })


  initPayment: (e) ->
    # console.log "Process Cash"
    $(@el).find('#modal-settlements .modal-content').html(@templateAddPayment())
    $(@el).find('#modal-settlements').modal('show')
    $(@el).find("#modal-settlements .datepicker").datepicker({dateFormat: "yy-mm-dd"})

  addPayment: (e) ->
    _this = @
    e.preventDefault()
    target = $(e.currentTarget).closest('.modal-body')

    data = {
      authenticity_token: $("#authenticity_token").val()
      payment: {
        amount: $(target).find('input[name=payment\\[amount\\]]').val()
        date: $(target).find('input[name=payment\\[date\\]]').val()
        note: $(target).find('textarea[name=payment\\[note\\]]').val()
        # payment_type: parseInt($(target).find("input[name=payment\\[payment_type\\]]:checked").val())
      }
      payment_type: parseInt($(target).find("input[name=payment_type]:checked").val())
      view: _this.params.view
    }

    # console.log data

    $.ajax({
      url: "settlements?id=" + @user_id
      type: "POST",
      data: data,
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          $(_this.el).find("#modal-settlements").modal('hide')
        #refresh data
        #update  summary and reports list
        _this.params.view_to_load = $(_this.el).find('.filter-status li.active a').attr('data-view') 
        _this.collection.fetch({
          data: _this.params
          reset: true,
          # data: _this.params
          success: ->
            _this.populateSummary(_this.user_id)

          error: ->
            console.log "Couldn't fetch Successfully."
        })
    })

  initCreditMoneyRequest: (e) ->
    _this = @
    e.preventDefault()
    requested_money = parseFloat($(@el).find('.summary input[name=pending_money_request]').val())
    console.log "requested_funds", requested_money
    $(@el).find('#modal-settlements .modal-content').html(@templateMoneyRequest())
    $(@el).find('#modal-settlements').modal('show')
    $(@el).find("#modal-settlements .datepicker").datepicker({dateFormat: "yy-mm-dd"})
    $(@el).find('#modal-settlements .modal-content .requested_money').text(requested_money)

    target = $(@el).find('#modal-settlements .modal-content .settlement-modal-reports')

    @params.view_to_load = 'approved_money_request'
    @params.id = @user_id
    # collection = new FinlyF.Collections.Settlements()
    @collectionSettlementReports.url = "/settlements/" + @user_id
    @collectionSettlementReports.fetch({
      data: @params
      reset: true,
      data: _this.params
      success: ->
        _this.collectionSettlementReports.each((item) ->
          view_item = new FinlyF.Views.Settlement({ model: item, page: 'money_request' })
          $(target).append(view_item.render().el)
          # console.log view_item.render
        , @)

      error: ->
        console.log "Couldn't fetch Successfully."
    })


  initDebt: (e) ->
    cash_in_hand = parseFloat($(@el).find('.summary input[name=cash_in_hand]').val())
    console.log "cash in hand", cash_in_hand
    $(@el).find('#modal-settlements .modal-content').html(@templateSettleDebts())
    $(@el).find('#modal-settlements').modal('show')
    $(@el).find("#modal-settlements .datepicker").datepicker({dateFormat: "yy-mm-dd"})
    $(@el).find('#modal-settlements .modal-content .cash_in_hand').text(cash_in_hand)
    e.preventDefault()
    _this = @
    target = $(@el).find('#modal-settlements .modal-content .settlement-modal-reports')

    @params.view_to_load = 'approved'
    @params.id = @user_id
    # collection = new FinlyF.Collections.Settlements()
    @collectionSettlementReports.url = "/settlements/" + @user_id
    @collectionSettlementReports.fetch({
      data: @params
      reset: true,
      data: _this.params
      success: ->
        _this.collectionSettlementReports.each((item) ->
          view_item = new FinlyF.Views.Settlement({ model: item, page: 'settle_debt' })
          $(target).append(view_item.render().el)
        , @)

      error: ->
        console.log "Couldn't fetch Successfully."
    })

  initReimburse: (e) ->
    pending_reimbursement = parseFloat($(@el).find('.summary input[name=pending_reimbursement]').val())
    $(@el).find('#modal-settlements .modal-content').html(@templateReimburse())
    $(@el).find('#modal-settlements').modal('show')
    $(@el).find("#modal-settlements .datepicker").datepicker({dateFormat: "yy-mm-dd"})
    $(@el).find('#modal-settlements .modal-content .pending_reimbursement').text(pending_reimbursement)
    e.preventDefault()
    _this = @
    target = $(@el).find('#modal-settlements .modal-content .settlement-modal-reports')

    @params.view_to_load = 'approved'
    @params.id = @user_id
    # collection = new FinlyF.Collections.Settlements()
    @collectionSettlementReports.url = "/settlements/" + @user_id
    @collectionSettlementReports.fetch({
      data: @params
      reset: true,
      data: _this.params
      success: ->
        _this.collectionSettlementReports.each((item) ->
          view_item = new FinlyF.Views.Settlement({ model: item, page: 'reimburse' })
          $(target).append(view_item.render().el)
        , @)

      error: ->
        console.log "Couldn't fetch Successfully."
    })

  confirmReportAction: (e)->
    #coming from confirmation screen
    _this = @
    e.preventDefault()
    target = e.currentTarget
    container = $(target).closest('.confirmation-screen')

    data = {
      view: _this.params.view
      payment: {
        note: $(container).find('textarea[name=payment\\[note\\]]').val()
        date: $(container).find('input[name=payment\\[date\\]]').val()
        amount: parseFloat(_this.selectedReportsTotal())
      }
    }


    if $(target).attr('data-action-type') == 'credit-money-request'
      data.money_request_ids = @selected.slice()
    else
      data.report_ids = @selected.slice()

    if $(target).attr('data-action-type') == 'reimburse'
      url = $(@el).find('.summary .btn-process-reimburse').attr('data-url')
    else if $(target).attr('data-action-type') == 'settle'
      url = $(@el).find('.summary .btn-process-debt').attr('data-url')
    else if $(target).attr('data-action-type') == 'credit-money-request'
      url = $(@el).find('.summary .btn-process-money-request').attr('data-url')

    $.ajax({
      url: url,
      data: data,
      type: "POST",
      dataType: 'json',
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          $(_this.el).find("#modal-settlements").modal('hide')

          #update  summary and reports list
          _this.params.view_to_load = $(_this.el).find('.filter-status li.active a').attr('data-view') 
          _this.collection.fetch({
            data: _this.params
            reset: true,
            # data: _this.params
            success: ->
              _this.populateSummary(_this.user_id)

            error: ->
              console.log "Couldn't fetch Successfully."
          })
      error: (err) ->
        console.log "err", err
    })

  ##Helpers
  processSettlementReport: (e) ->
    _this = @
    container = $(e.currentTarget).closest('.settlement-modal-reports')
    reports =  $(container).find('.settlement-report')
    flag = false
    @selected = []
    for report in reports
      if $(report).find('.settlement-report-select:checkbox').prop('checked')
        flag = true
        @selected.push parseInt($(report).find('.settlement-report-select:checkbox').attr('data-item-id'))
        # return
    if flag == true
      $(container).closest('.modal-body').find('.btn-settlement-action').prop('disabled', false)
    else
      $(container).closest('.modal-body').find('.btn-settlement-action').prop('disabled', true)

    @selectedReports = _.select(@collectionSettlementReports.models, (model) ->
      (_.indexOf(_this.selected, model.get('id')) > -1)
    )
    $(container).closest('.modal-body').find('.selected_reports_total').text(@selectedReportsTotal())

  processSettlementAction: (e) ->
    _this = @
    container = $(e.currentTarget).closest('.modal-body')
    $(container).find('.confirmation-screen').css("display", "block")
    $(container).find('.process-screen').css('display', 'none')

  cancelConfirmation: (e) ->
    e.preventDefault()
    container = $(e.currentTarget).closest('.modal-body')
    $(container).find('.confirmation-screen').css("display", "none")
    $(container).find('.process-screen').css('display', 'block')

  selectedReportsTotal: ->
    total = _.reduce(@selectedReports, ((memo, value) ->
      memo + (value.get('reimbursement_amount') || value.get('total_amount'))
    ), 0)
    return total