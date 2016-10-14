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
  templateMainRequestsApproved: HandlebarsTemplates['finlyf/settlements/crud/indexRequestsApproved']
  templateMainRequestsCredited: HandlebarsTemplates['finlyf/settlements/crud/indexRequestsCredited']

  #settlements
  templateAddPayment: HandlebarsTemplates['finlyf/settlements/admin/addPayment']
  templateSettleDebts: HandlebarsTemplates['finlyf/settlements/admin/settleDebts']
  templateReimburse: HandlebarsTemplates['finlyf/settlements/admin/reimburse']
  templateMoneyRequest: HandlebarsTemplates['finlyf/settlements/admin/moneyRequest']


  #new Templates
  templateProcessCredit: HandlebarsTemplates['finlyf/settlements/settlement_actions/processCredit']
  templateProcessDebit: HandlebarsTemplates['finlyf/settlements/settlement_actions/processDebit']

  tCreditReimburse: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/reimburse']
  tCreditReimburseConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/reimburse_confirm']
  # templateBaseSettlement: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/_settlement']
  tCreditCashAdvance: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/cash_advance']
  tCreditCashAdvanceConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/cash_advance_confirm']
  tCreditMoneyRequest: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/money_request']
  tCreditMoneyRequestConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/money_request_confirm']
  tCreditCardFromCard: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/card_from_card']
  tCreditCardFromCardConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/card_from_card_confirm']
  tCreditCardFromCompanyCredits: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/card_from_company_credits']
  tCreditCardFromCompanyCreditsConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/card_from_company_credits_confirm']

  tDebitCashAdvance: HandlebarsTemplates['finlyf/settlements/settlement_actions/debit/cash_advance']
  tDebitCashAdvanceConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/debit/cash_advance_confirm']
  tDebitCardToCard: HandlebarsTemplates['finlyf/settlements/settlement_actions/debit/card_to_card']
  tDebitCardToCardConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/debit/card_to_card_confirm']
  tDebitCardToCompanyCredits: HandlebarsTemplates['finlyf/settlements/settlement_actions/debit/card_to_company_credits']
  tDebitCardToCompanyCreditsConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/debit/card_to_company_credits_confirm']

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

    # 'click .btn-process-reimburse': 'initReimburse'
    # 'click .btn-process-debt': 'initDebt'
    # 'click .btn-process-payment': 'initPayment'
    # 'click .btn-process-money-request': 'initCreditMoneyRequest'
    # 'change input[type=radio][name=advance_request_type]': 'loadRequstedAdvanceList' 

    #settlements
    'click .btn-back-step-2': 'cancelConfirmation'
    # 'click .btn-add-payment': 'addPayment'
    # 'click .settlement-report': 'processSettlementReport'
    'click .settlement-report-select:checkbox': 'processSettlementReport'
    # 'click .btn-settlement-action': 'processSettlementAction'
    # 'click .confirm-report-action': 'confirmReportAction'
    'keyup .search-user': 'prepareSearch'
    'submit .navbar-form': 'cancelEvents'

    #New actions
    'click .btn-summary-action.btn-debit': 'processDebit'
    'click .btn-summary-action.btn-credit': 'processCredit'
    'change input[name=settlement_credit_action]': 'creditDebitOptions'

    #Step 2 Action
    'click .step-2-action': 'confirmAction'
    'click .step-3-action': 'submitAction'

    #selecting all settlement action items; later report should be changed to item
    'click .settlement-report-select:checkbox': 'processSettlementReport'

    'mouseenter ul.settlement-actions li': 'showActionDefinition'
    'mouseleave ul.settlement-actions li': 'hideActionDefinition'


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
        @selectedUserSummary = {}
        @settlementActionData = {
          c_cash_advance: {}
          c_card_from_card: {}
          c_card_from_company_credits: {}
          d_card_to_card: {}
          d_card_to_company_credits: {}
          d_cash_advance: {}
        }
        # @selected = []
        # @selectedReports = []
        # console.log "params for admin is", @params
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
        else if @params.view_to_load == "credited_money_request"
          $(@el).find(".settlements-index").html(@templateMainRequestsCredited({item: @params}))
        else if @params.view_to_load == "approved_money_request"
          $(@el).find(".settlements-index").html(@templateMainRequestsApproved({item: @params}))
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
          _this.selectedUserSummary = res
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
    view_item = new FinlyF.Views.Settlement({ model: item, params: @params })
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
      else if view_to_load == "approved_money_request"
        $(@el).find(".settlements-index").html(@templateMainRequestsApproved({item: {view_to_load: view_to_load}}))
      else if view_to_load == "credited_money_request"
        $(@el).find(".settlements-index").html(@templateMainRequestsCredited({item: {view_to_load: view_to_load}}))
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


  # initPayment: (e) ->
  #   # console.log "Process Cash"
  #   e.preventDefault()
  #   target = e.currentTarget

  #   payment_type = $(target).attr('data-payment-type')
  #   if parseInt(payment_type) == 1
  #     item = {
  #       payment_type: 1
  #       modal_title: "Add New Payment"
  #       button_title: "Add Payment"
  #     }
  #   else if parseInt(payment_type) == 2
  #     item = {
  #       payment_type: 2
  #       modal_title: "Clear Debts"
  #       button_title: "Clear Debts"
  #     }


  #   $(@el).find('#modal-settlements .modal-content').html(@templateAddPayment({item: item}))
  #   $(@el).find('#modal-settlements').modal('show')
  #   $(@el).find("#modal-settlements .datepicker").datepicker({dateFormat: "yy-mm-dd"})

  # addPayment: (e) ->
  #   _this = @
  #   e.preventDefault()
  #   target = $(e.currentTarget).closest('.modal-body')

  #   data = {
  #     authenticity_token: $("#authenticity_token").val()
  #     payment: {
  #       amount: $(target).find('input[name=payment\\[amount\\]]').val()
  #       date: $(target).find('input[name=payment\\[date\\]]').val()
  #       note: $(target).find('textarea[name=payment\\[note\\]]').val()
  #       # payment_type: parseInt($(target).find("input[name=payment\\[payment_type\\]]:checked").val())
  #     }
  #     payment_type: parseInt($(target).find("input[name=payment_type]").val())
  #     view: _this.params.view
  #     password: $(target).find('input[name=password]').val()
  #   }

  #   # console.log data

  #   $.ajax({
  #     url: "settlements?id=" + @user_id
  #     type: "POST",
  #     data: data,
  #     success: (res) ->
  #       FinlyF.snapNotify(res.messages)
  #       if res.success == true
  #         $(_this.el).find("#modal-settlements").modal('hide')
  #       #refresh data
  #       #update  summary and reports list
  #       _this.params.view_to_load = $(_this.el).find('.filter-status li.active a').attr('data-view') 
  #       _this.collection.fetch({
  #         data: _this.params
  #         reset: true,
  #         # data: _this.params
  #         success: ->
  #           _this.populateSummary(_this.user_id)

  #         error: ->
  #           console.log "Couldn't fetch Successfully."
  #       })
  #   })

  # initCreditMoneyRequest: (e) ->
  #   _this = @
  #   e.preventDefault()
  #   requested_money = parseFloat($(@el).find('.summary input[name=pending_money_request]').val())
  #   console.log "requested_funds", requested_money
  #   $(@el).find('#modal-settlements .modal-content').html(@templateMoneyRequest())
  #   $(@el).find('#modal-settlements').modal('show')
  #   $(@el).find("#modal-settlements .datepicker").datepicker({dateFormat: "yy-mm-dd"})
  #   $(@el).find('#modal-settlements .modal-content .requested_money').text(requested_money)

  #   target = $(@el).find('#modal-settlements .modal-content .settlement-modal-reports')

  #   @params.view_to_load = 'approved_money_request'
  #   @params.id = @user_id

  #   # @params.payment_mode_id = 1
  #   # collection = new FinlyF.Collections.Settlements()
  #   @collectionSettlementReports.url = "/settlements/" + @user_id
  #   @collectionSettlementReports.fetch({
  #     data: @params
  #     reset: true,
  #     data: _this.params
  #     success: ->
  #       _this.collectionSettlementReports.each((item) ->
  #         if parseInt(item.get('payment_mode_id')) == 1#hard coding for the first time to show cash requested
  #           view_item = new FinlyF.Views.Settlement({ model: item, page: 'money_request' })
  #           $(target).append(view_item.render().el)
  #       , @)

  #     error: ->
  #       console.log "Couldn't fetch Successfully."
  #   })

  # loadRequstedAdvanceList: (e) ->
  #   _this = @
  #   # alert("You changed")
  #   payment_mode_id = $("input[type=radio][name=advance_request_type]:checked").val()

  #   $(@el).find('#modal-settlements .modal-content .selected_reports_total').text("0")

  #   target = $(@el).find('#modal-settlements .modal-content .settlement-modal-reports')
  #   $(target).html("")

  #   @params.view_to_load = 'approved_money_request'
  #   @params.id = @user_id
  #   # @params.payment_mode_id = payment_mode_id
  #   # collection = new FinlyF.Collections.Settlements()
  #   @collectionSettlementReports.each((item) ->
  #     if parseInt(item.get('payment_mode_id')) == parseInt(payment_mode_id)
  #       view_item = new FinlyF.Views.Settlement({ model: item, page: 'money_request' })
  #       $(target).append(view_item.render().el)
  #       # console.log view_item.render
  #   , @)



    # @collectionSettlementReports.url = "/settlements/" + @user_id
    # @collectionSettlementReports.fetch({
    #   data: @params
    #   reset: true,
    #   data: _this.params
    #   success: ->
    #     _this.collectionSettlementReports.each((item) ->
    #       if parseInt(item.get('payment_mode_id')) == parseInt(payment_mode_id)
    #         view_item = new FinlyF.Views.Settlement({ model: item, page: 'money_request' })
    #         $(target).append(view_item.render().el)
    #         # console.log view_item.render
    #     , @)

    #   error: ->
    #     console.log "Couldn't fetch Successfully."
    # })


  # initDebt: (e) ->
  #   cash_in_hand = parseFloat($(@el).find('.summary input[name=cash_in_hand]').val())
  #   console.log "cash in hand", cash_in_hand
  #   $(@el).find('#modal-settlements .modal-content').html(@templateSettleDebts())
  #   $(@el).find('#modal-settlements').modal('show')
  #   $(@el).find("#modal-settlements .datepicker").datepicker({dateFormat: "yy-mm-dd"})
  #   $(@el).find('#modal-settlements .modal-content .cash_in_hand').text(cash_in_hand)
  #   e.preventDefault()
  #   _this = @
  #   target = $(@el).find('#modal-settlements .modal-content .settlement-modal-reports')

  #   @params.view_to_load = 'approved'
  #   @params.id = @user_id
  #   # collection = new FinlyF.Collections.Settlements()
  #   @collectionSettlementReports.url = "/settlements/" + @user_id
  #   @collectionSettlementReports.fetch({
  #     data: @params
  #     reset: true,
  #     data: _this.params
  #     success: ->
  #       _this.collectionSettlementReports.each((item) ->
  #         view_item = new FinlyF.Views.Settlement({ model: item, page: 'settle_debt' })
  #         $(target).append(view_item.render().el)
  #       , @)

  #     error: ->
  #       console.log "Couldn't fetch Successfully."
  #   })

  # initReimburse: (e) ->
  #   pending_reimbursement = parseFloat($(@el).find('.summary input[name=pending_reimbursement]').val())
  #   $(@el).find('#modal-settlements .modal-content').html(@templateReimburse())
  #   $(@el).find('#modal-settlements').modal('show')
  #   $(@el).find("#modal-settlements .datepicker").datepicker({dateFormat: "yy-mm-dd"})
  #   $(@el).find('#modal-settlements .modal-content .pending_reimbursement').text(pending_reimbursement)
  #   e.preventDefault()
  #   _this = @
  #   target = $(@el).find('#modal-settlements .modal-content .settlement-modal-reports')

  #   @params.view_to_load = 'approved'
  #   @params.id = @user_id
  #   # collection = new FinlyF.Collections.Settlements()
  #   @collectionSettlementReports.url = "/settlements/" + @user_id
  #   @collectionSettlementReports.fetch({
  #     data: @params
  #     reset: true,
  #     data: _this.params
  #     success: ->
  #       _this.collectionSettlementReports.each((item) ->
  #         view_item = new FinlyF.Views.Settlement({ model: item, page: 'reimburse' })
  #         $(target).append(view_item.render().el)
  #       , @)

  #     error: ->
  #       console.log "Couldn't fetch Successfully."
  #   })

  # confirmReportAction: (e)->
  #   #coming from confirmation screen
  #   _this = @
  #   e.preventDefault()
  #   target = e.currentTarget
  #   container = $(target).closest('.confirmation-screen')

  #   data = {
  #     view: _this.params.view
  #     payment: {
  #       note: $(container).find('textarea[name=payment\\[note\\]]').val()
  #       date: $(container).find('input[name=payment\\[date\\]]').val()
  #       amount: parseFloat(_this.selectedReportsTotal())
  #     }
  #   }


  #   if $(target).attr('data-action-type') == 'credit-money-request'
  #     data.money_request_ids = @selected.slice()
  #   else
  #     data.report_ids = @selected.slice()

  #   if $(target).attr('data-action-type') == 'reimburse'
  #     url = $(@el).find('.summary .btn-process-reimburse').attr('data-url')
  #   else if $(target).attr('data-action-type') == 'settle'
  #     url = $(@el).find('.summary .btn-process-debt').attr('data-url')
  #   else if $(target).attr('data-action-type') == 'credit-money-request'
  #     url = $(@el).find('.summary .btn-process-money-request').attr('data-url')

  #   $.ajax({
  #     url: url,
  #     data: data,
  #     type: "POST",
  #     dataType: 'json',
  #     success: (res) ->
  #       FinlyF.snapNotify(res.messages)
  #       if res.success == true
  #         $(_this.el).find("#modal-settlements").modal('hide')

  #         #update  summary and reports list
  #         _this.params.view_to_load = $(_this.el).find('.filter-status li.active a').attr('data-view') 
  #         _this.collection.fetch({
  #           data: _this.params
  #           reset: true,
  #           # data: _this.params
  #           success: ->
  #             _this.populateSummary(_this.user_id)

  #           error: ->
  #             console.log "Couldn't fetch Successfully."
  #         })
  #     error: (err) ->
  #       console.log "err", err
  #   })



  ##Helpers
  processSettlementReport: (e) ->
    _this = @
    container = $(e.currentTarget).closest('.settlement-action-items')
    reports =  $(container).find('.settlement-report')
    flag = false
    @settlementActionData.selected = []
    for report in reports
      if $(report).find('.settlement-report-select:checkbox').prop('checked')
        flag = true
        @settlementActionData.selected.push parseInt($(report).find('.settlement-report-select:checkbox').attr('data-item-id'))
        # return
    if flag == true
      $(container).closest('.modal-body').find('.btn-settlement-action').prop('disabled', false)
    else
      $(container).closest('.modal-body').find('.btn-settlement-action').prop('disabled', true)

    @settlementActionData.selectedReports = _.select(@collectionSettlementReports.models, (model) ->
      (_.indexOf(_this.settlementActionData.selected, model.get('id')) > -1)
    )
    $(container).closest('.modal-body').find('.selected_items_total').text(@selectedReportsTotal())

  showActionDefinition: (e) ->
    # console.log "Hovering"
    target = e.currentTarget

    definition = $(target).find('label.hidden').text()
    div_definition = $(target).closest('.modal-body').find('.settlement-action-definition')

    $(div_definition).removeClass('hidden').text(definition) 

    # console.log definition

  hideActionDefinition: (e) ->
    target = e.currentTarget
    siblings = $(target).closest('ul').find('li')
    div_definition = $(target).closest('.modal-body').find('.settlement-action-definition')

    flag_action_selected = false
    for sibling in siblings
      if $(sibling).find('input[type=radio]:checked').length > 0
        # console.log "Found Checked"
        selected_action = sibling
        flag_action_selected = true

    unless flag_action_selected
      $(div_definition).text("Credits & shit!")
    else
      definition = $(selected_action).find('label.hidden').text()
      $(div_definition).text(definition)

    # div_definition = $(target).closest('.modal-body').find('.settlement-action-definition')
    # $(div_definition).addClass('hidden')

  processDebit: (e) ->
    e.preventDefault()
    target = e.currentTarget

    modal = $(@el).find("#modal-settlements")
    $(modal).modal('show')

    # console.log "Summary", summary
    $(modal).html(@templateProcessDebit({summary: @selectedUserSummary}))

    #set height of summary
    # console.log $(modal).find(".settlement-action-types").height()
    # console.log $(modal).find(".settlement-action-types").html()
    # $(modal).find(".settlement-action-definition").height($(modal).find(".settlement-action-types").height())


  processCredit: (e) ->
    e.preventDefault()
    target = e.currentTarget

    modal = $(@el).find("#modal-settlements")
    $(modal).modal('show')

    # console.log "Summary", @selectedUserSummary
    $(modal).html(@templateProcessCredit({summary: @selectedUserSummary}))

  creditDebitOptions: (e) ->
    _this = @
    target = e.currentTarget
    action_type = $(target).attr('data-action-type')

    # adding active clss and removing
    lis = $(target).closest('ul').find('li')
    for li in lis
      $(li).removeClass('active')

    $(target).closest('li').addClass('active')

    definition = $(target).find('label.hidden').text()
    div_definition = $(target).closest('.modal-body').find('.settlement-action-definition')

    $(div_definition).text(definition) 


    modal_body = $(target).closest('.modal-body')
    $(modal_body).find('#collapse-step-1').collapse('hide')
    $(modal_body).find('#collapse-step-2').collapse('show')

    switch action_type
      when 'credit_reimbursement'
        $(modal_body).find(".settlement-step-1 .panel-title a").text("Type: Credit Reimbursement")
        $(modal_body).find(".settlement-step-2 .panel-title a").text("Select Reports to be Reimbursed")
        #Append base structure
        $(modal_body).find('.settlement-step-2 .panel-body').html(@tCreditReimburse({summary: @selectedUserSummary}))

        report_container = $(modal_body).find('.settlement-action-items')
        #Load reports
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
              $(report_container).append(view_item.render().el)
            , @)

          error: ->
            console.log "Couldn't fetch Successfully."
        })

      # when 'credit_settle', 'debit_settle'
        # $(modal_body).find(".settlement-step-1 .panel-title a").text("Type: Credit & Settle")
        # $(modal_body).find(".settlement-step-2 .panel-title a").text("Select Reports to ")
        # #Append base structure
        # $(modal_body).find('.settlement-step-2 .panel-body').html(@templateBaseSettlement({summary: @selectedUserSummary}))

        # report_container = $(modal_body).find('.settlement-action-items')
        # #Load reports
        # @params.view_to_load = 'approved'
        # @params.id = @user_id
        # # collection = new FinlyF.Collections.Settlements()
        # @collectionSettlementReports.url = "/settlements/" + @user_id
        # @collectionSettlementReports.fetch({
        #   data: @params
        #   reset: true,
        #   data: _this.params
        #   success: ->
        #     _this.collectionSettlementReports.each((item) ->
        #       view_item = new FinlyF.Views.Settlement({ model: item, page: 'reimburse' })
        #       $(report_container).append(view_item.render().el)
        #     , @)

        #   error: ->
        #     console.log "Couldn't fetch Successfully."
        # })

      when 'credit_cash_advance'
        $(modal_body).find(".settlement-step-1 .panel-title a").text("Type: Add Cash Advance")
        #Append base structure
        $(modal_body).find('.settlement-step-2 .panel-body').html(@tCreditCashAdvance({summary: @selectedUserSummary}))
      when 'credit_money_request'#advance funds request
        $(modal_body).find(".settlement-step-1 .panel-title a").text("Type: Credit Advance Requests")
        #Append base structure
        $(modal_body).find('.settlement-step-2 .panel-body').html(@tCreditMoneyRequest({summary: @selectedUserSummary}))

        items_container = $(modal_body).find('.settlement-action-items')
        #Load reports
        @params.view_to_load = 'approved_money_request'
        @params.id = @user_id

        # @params.payment_mode_id = 1
        # collection = new FinlyF.Collections.Settlements()
        @collectionSettlementReports.url = "/settlements/" + @user_id
        @collectionSettlementReports.fetch({
          data: @params
          reset: true,
          data: _this.params
          success: ->
            _this.collectionSettlementReports.each((item) ->
              # if parseInt(item.get('payment_mode_id')) == 1#hard coding for the first time to show cash requested
              #   view_item = new FinlyF.Views.Settlement({ model: item, page: 'money_request' })
              #   $(target).append(view_item.render().el)
              view_item = new FinlyF.Views.Settlement({ model: item, page: 'money_request' })
              $(items_container).append(view_item.render().el)

            , @)

          error: ->
            console.log "Couldn't fetch Successfully."
        })
      when 'credit_card_from_card'
        $(modal_body).find(".settlement-step-1 .panel-title a").text("Type: Credit from Your Card")
        # console.log "Credit card from card" 
        $(modal_body).find('.settlement-step-2 .panel-body').html(@tCreditCardFromCard({summary: @selectedUserSummary}))
      when 'credit_card_from_company_credits'
        $(modal_body).find(".settlement-step-1 .panel-title a").text("Type: Credit from Company Credits")
        $(modal_body).find('.settlement-step-2 .panel-body').html(@tCreditCardFromCompanyCredits({summary: @selectedUserSummary}))
      #DEBIT ACTIONS
      when 'debit_cash_advance'
        $(modal_body).find(".settlement-step-1 .panel-title a").text("Type: Debit Cash Advance")
        #Append base structure
        $(modal_body).find('.settlement-step-2 .panel-body').html(@tDebitCashAdvance({summary: @selectedUserSummary}))
      when 'debit_card_to_card' 
        $(modal_body).find(".settlement-step-1 .panel-title a").text("Type: Debit Balance to Your Card")
        $(modal_body).find('.settlement-step-2 .panel-body').html(@tDebitCardToCard({summary: @selectedUserSummary}))
      when 'debit_card_to_company_credits' 
        $(modal_body).find(".settlement-step-1 .panel-title a").text("Type: Debit Balance to Company Credits")
        $(modal_body).find('.settlement-step-2 .panel-body').html(@tDebitCardToCompanyCredits({summary: @selectedUserSummary}))

    $(modal_body).find(".datepicker").datepicker({dateFormat: "yy-mm-dd"})

  confirmAction: (e) ->
    # @settlementActionData = {}
    e.preventDefault()
    _this = @
    target = e.currentTarget

    action_type = $(target).attr('data-action-type')
    modal_body = $(target).closest('.modal-body')
    container = $(target).closest("#collapse-step-2")
    $(modal_body).find('#collapse-step-2').collapse('hide')
    $(modal_body).find('#collapse-step-3').collapse('show')

    switch action_type
      when 'credit_reimbursement'
        #Setup and how colapse 3
        $(modal_body).find(".settlement-step-3 .panel-title a").text("Additional Note")
        #Append base structure
        $(modal_body).find('.settlement-step-3 .panel-body').html(@tCreditReimburseConfirm({summary: @selectedUserSummary}))

        #Collect relevant data from Step 2
        # container = $(e.currentTarget).closest('.settlement-action-items')
        # reports =  $(container).find('.settlement-report')
        # flag = false
        # _this.settlementActionData.selected = []
        # for report in reports
        #   if $(report).find('.settlement-report-select:checkbox').prop('checked')
        #     # flag = true
        #     console.log "Found one"
        #     _this.settlementActionData.selected.push parseInt($(report).find('.settlement-report-select:checkbox').attr('data-item-id'))
            # return
        # if flag == true
        #   $(container).closest('.modal-body').find('.btn-settlement-action').prop('disabled', false)
        # else
        #   $(container).closest('.modal-body').find('.btn-settlement-action').prop('disabled', true)

        # @selectedReports = _.select(@collectionSettlementReports.models, (model) ->
        #   (_.indexOf(_this.selected, model.get('id')) > -1)
        # )
        # $(container).closest('.modal-body').find('.selected_items_total').text(@selectedReportsTotal())

      when 'credit_cash_advance'
        $(modal_body).find(".settlement-step-3 .panel-title a").text("Authorize Payment")
        #Append base structure
        $(modal_body).find('.settlement-step-3 .panel-body').html(@tCreditCashAdvanceConfirm({summary: @selectedUserSummary}))
        _this.settlementActionData.c_cash_advance.amount = $(container).find('input[name=payment\\[amount\\]]').val()
        _this.settlementActionData.c_cash_advance.date = $(container).find('input[name=payment\\[date\\]]').val()
        _this.settlementActionData.c_cash_advance.note = $(container).find('textarea[name=payment\\[note\\]]').val()

      when 'credit_money_request'
        $(modal_body).find(".settlement-step-3 .panel-title a").text("Authorize Payment")
        $(modal_body).find('.settlement-step-3 .panel-body').html(@tCreditMoneyRequestConfirm({summary: @selectedUserSummary}))

      when 'credit_card_from_card'
        $(modal_body).find(".settlement-step-3 .panel-title a").text("Authorize Payment")
        $(modal_body).find('.settlement-step-3 .panel-body').html(@tCreditCardFromCardConfirm({summary: @selectedUserSummary}))
        _this.settlementActionData.c_card_from_card.amount = $(container).find('input[name=amount]').val()
      when 'credit_card_from_company_credits'
        $(modal_body).find(".settlement-step-3 .panel-title a").text("Authorize Payment")
        $(modal_body).find('.settlement-step-3 .panel-body').html(@tCreditCardFromCompanyCreditsConfirm({summary: @selectedUserSummary}))
        _this.settlementActionData.c_card_from_company_credits.amount = $(container).find('input[name=amount]').val()
      when 'debit_cash_advance'
        $(modal_body).find(".settlement-step-3 .panel-title a").text("Authorize Payment")
        $(modal_body).find('.settlement-step-3 .panel-body').html(@tDebitCashAdvanceConfirm({summary: @selectedUserSummary}))
        _this.settlementActionData.d_cash_advance.amount = $(container).find('input[name=payment\\[amount\\]]').val()
        _this.settlementActionData.d_cash_advance.date = $(container).find('input[name=payment\\[date\\]]').val()
        _this.settlementActionData.d_cash_advance.note = $(container).find('textarea[name=payment\\[note\\]]').val()
      when 'debit_card_to_card' 
        $(modal_body).find(".settlement-step-3 .panel-title a").text("Authorize Payment")
        $(modal_body).find('.settlement-step-3 .panel-body').html(@tDebitCardToCardConfirm({summary: @selectedUserSummary}))
        _this.settlementActionData.d_card_to_card.amount = $(container).find('input[name=amount]').val()
      when 'debit_card_to_company_credits' 
        $(modal_body).find(".settlement-step-3 .panel-title a").text("Authorize Payment")
        $(modal_body).find('.settlement-step-3 .panel-body').html(@tDebitCardToCompanyCreditsConfirm({summary: @selectedUserSummary}))
        _this.settlementActionData.d_card_to_company_credits.amount = $(container).find('input[name=amount]').val()
    # console.log _this.settlementActionData
    $(modal_body).find(".datepicker").datepicker({dateFormat: "yy-mm-dd"})

  submitAction: (e) ->
    e.preventDefault()
    _this = @
    target = e.currentTarget

    action_type = $(target).attr('data-action-type')
    modal_body = $(target).closest('.modal-body')
    $(modal_body).find('#collapse-step-2').collapse('hide')
    $(modal_body).find('#collapse-step-3').collapse('show')

    container = $(target).closest('#collapse-step-3')

    url = $(target).attr('data-url')
    data = {}
    data.view = _this.params.view
    data.authenticity_token = $("#authenticity_token").val()

    switch action_type
      when 'credit_reimbursement'
        # console.log "Selected data",_this.settlementActionData
        # data.report_ids = _this.settlementActionData.selected.slice()
        data.report_ids = _this.settlementActionData.selected.slice()
        data.payment = {
          note: $(container).find('textarea[name=payment\\[note\\]]').val()
          date: $(container).find('input[name=payment\\[date\\]]').val()
          amount: parseFloat(_this.selectedReportsTotal())
        }
        # console.log data
      when 'credit_cash_advance'
        data.payment = {
          amount: _this.settlementActionData.c_cash_advance.amount
          date: _this.settlementActionData.c_cash_advance.date
          note: _this.settlementActionData.c_cash_advance.note
          # payment_type: parseInt($(target).find("input[name=payment\\[payment_type\\]]:checked").val())
        }
        # data.payment_type = parseInt($(target).find("input[name=payment_type]").val())
        # data.payment_type = 1 #Already there in the url
        data.password = $(container).find('input[name=password]').val()

      when 'credit_money_request'
        data.money_request_ids = _this.settlementActionData.selected.slice()
        data.payment = {
          note: $(container).find('textarea[name=payment\\[note\\]]').val()
          date: $(container).find('input[name=payment\\[date\\]]').val()
          amount: parseFloat(_this.selectedReportsTotal())
        }
      when 'credit_card_from_card'
        # data.action_type = x
        data.amount = _this.settlementActionData.c_card_from_card.amount
        data.password = $(container).find('input[type=password][name=password]').val()
        data.to_user_id = _this.user_id

      when 'credit_card_from_company_credits'
        data.amount = _this.settlementActionData.c_card_from_company_credits.amount
        data.password = $(container).find('input[type=password][name=password]').val()
        data.to_user_id = _this.user_id

      when 'debit_cash_advance'
        data.payment = {
          amount: _this.settlementActionData.d_cash_advance.amount
          date: _this.settlementActionData.d_cash_advance.date
          note: _this.settlementActionData.d_cash_advance.note
          # payment_type: parseInt($(target).find("input[name=payment\\[payment_type\\]]:checked").val())
        }
        # data.payment_type = parseInt($(target).find("input[name=payment_type]").val())
        # data.payment_type = 1 #Already there in the url
        data.password = $(container).find('input[name=password]').val()

      when 'debit_card_to_card'
        data.amount = _this.settlementActionData.d_card_to_card.amount
        data.password = $(container).find('input[type=password][name=password]').val()
        data.from_user_id = _this.user_id
      when 'debit_card_to_company_credits'
        data.amount = _this.settlementActionData.d_card_to_company_credits.amount
        data.password = $(container).find('input[type=password][name=password]').val()
        data.from_user_id = _this.user_id

    console.log data
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

  # processSettlementAction: (e) ->
  #   _this = @
  #   container = $(e.currentTarget).closest('.modal-body')
  #   $(container).find('.confirmation-screen').css("display", "block")
  #   $(container).find('.process-screen').css('display', 'none')

  cancelConfirmation: (e) ->
    e.preventDefault()
    target = e.currentTarget
    container = $(e.currentTarget).closest('.modal-body')
    $(container).find('.confirmation-screen').css("display", "none")
    $(container).find('.process-screen').css('display', 'block')

  selectedReportsTotal: ->
    total = _.reduce(@settlementActionData.selectedReports, ((memo, value) ->
      memo + (value.get('reimbursement_amount') || value.get('total_amount'))
    ), 0)
    return total
