class FinlyF.Views.SettlementsIndex extends Backbone.View
  templateSkeleton: HandlebarsTemplates['finlyf/settlements/skeleton']
  templateSkeletonAdmin: HandlebarsTemplates['finlyf/settlements/skeletonAdmin']

  #sidebar
  templateSidebarAdmin: HandlebarsTemplates['finlyf/settlements/sidebar/sidebar_admin']

  templateNavbarMain: HandlebarsTemplates['finlyf/settlements/navbar/navbar_main']
  templateNavbarMainPersonal: HandlebarsTemplates['finlyf/settlements/navbar/navbar_main_personal']
  templateSidebarPersonal: HandlebarsTemplates['finlyf/settlements/sidebar/sidebar_personal']
  templateNavbarSidebar: HandlebarsTemplates['finlyf/settlements/navbar/navbar_sidebar']

  #main

  templateSummary: HandlebarsTemplates['finlyf/settlements/summary']
  templateSummaryAdmin: HandlebarsTemplates['finlyf/settlements/summaryAdmin']
  templateMainReports: HandlebarsTemplates['finlyf/settlements/crud/indexReports']
  templateMain: HandlebarsTemplates['finlyf/settlements/crud/index']
  templateMainPayments: HandlebarsTemplates['finlyf/settlements/crud/indexPayments']
  templateMainMoneyRequests: HandlebarsTemplates['finlyf/settlements/crud/indexMoneyRequests']
  templateMainRequestsApproved: HandlebarsTemplates['finlyf/settlements/crud/indexRequestsApproved']
  templateMainRequestsCredited: HandlebarsTemplates['finlyf/settlements/crud/indexRequestsCredited']

  #settlements
  # templateAddPayment: HandlebarsTemplates['finlyf/settlements/admin/addPayment']
  # templateSettleDebts: HandlebarsTemplates['finlyf/settlements/admin/settleDebts']
  # templateReimburse: HandlebarsTemplates['finlyf/settlements/admin/reimburse']
  # templateMoneyRequest: HandlebarsTemplates['finlyf/settlements/admin/moneyRequest']


  # #new Templates
  # templateProcessCredit: HandlebarsTemplates['finlyf/settlements/settlement_actions/processCredit']
  # templateProcessDebit: HandlebarsTemplates['finlyf/settlements/settlement_actions/processDebit']

  ###### tCreditReimburse: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/reimburse']
  # tCreditReimburseConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/reimburse_confirm']
  # # templateBaseSettlement: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/_settlement']
  # tCreditCashAdvance: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/cash_advance']
  # tCreditCashAdvanceConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/cash_advance_confirm']
  # tCreditMoneyRequest: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/money_request']
  # tCreditMoneyRequestConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/money_request_confirm']
  # tCreditCardFromCard: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/card_from_card']
  # tCreditCardFromCardConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/card_from_card_confirm']
  # tCreditCardFromWallet: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/card_from_wallet']
  # tCreditCardFromWalletConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/card_from_wallet_confirm']
  # tCreditWalletFromWallet: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/wallet_from_wallet']
  # tCreditWalletFromWalletConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/wallet_from_wallet_confirm']
  # tCreditCardFromVirtualAccount: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/card_from_virtual_account']
  # tCreditCardFromVirtualAccountConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/card_from_virtual_account_confirm']
  # tCreditWalletFromVirtualAccount: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/wallet_from_virtual_account']
  # tCreditWalletFromVirtualAccountConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/credit/wallet_from_virtual_account_confirm']

  # tDebitCashAdvance: HandlebarsTemplates['finlyf/settlements/settlement_actions/debit/cash_advance']
  # tDebitCashAdvanceConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/debit/cash_advance_confirm']
  # tDebitCardToCard: HandlebarsTemplates['finlyf/settlements/settlement_actions/debit/card_to_card']
  # tDebitCardToCardConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/debit/card_to_card_confirm']
  # tDebitCardToWallet: HandlebarsTemplates['finlyf/settlements/settlement_actions/debit/card_to_wallet']
  # tDebitCardToWalletConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/debit/card_to_wallet_confirm']
  # tDebitWalletToWallet: HandlebarsTemplates['finlyf/settlements/settlement_actions/debit/wallet_to_wallet']
  # tDebitWalletToWalletConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/debit/wallet_to_wallet_confirm']
  # tDebitCardToCompanyCredits: HandlebarsTemplates['finlyf/settlements/settlement_actions/debit/card_to_company_credits']
  # tDebitCardToCompanyCreditsConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/debit/card_to_company_credits_confirm']
  # tDebitWalletToVirtualAccount: HandlebarsTemplates['finlyf/settlements/settlement_actions/debit/wallet_to_virtual_account']
  # tDebitWalletToVirtualAccountConfirm: HandlebarsTemplates['finlyf/settlements/settlement_actions/debit/wallet_to_virtual_account_confirm']


  

  # New Action workflow
  templateProcessAction: HandlebarsTemplates['finlyf/settlements/settlement_actions/processAction']

  # Step 1
  tInitReports: HandlebarsTemplates['finlyf/settlements/settlement_actions/init/reports']
  tInitMoneyRequests: HandlebarsTemplates['finlyf/settlements/settlement_actions/init/moneyRequests']

  tInitCreditCash: HandlebarsTemplates['finlyf/settlements/settlement_actions/init/creditCash']
  tInitDebitCash: HandlebarsTemplates['finlyf/settlements/settlement_actions/init/debitCash']



  tInitLoadFundsCard: HandlebarsTemplates['finlyf/settlements/settlement_actions/init/loadFundsCard']
  tInitWithdrawFundsCard: HandlebarsTemplates['finlyf/settlements/settlement_actions/init/withdrawFundsCard']
  tInitLoadFundsFinlyMoney: HandlebarsTemplates['finlyf/settlements/settlement_actions/init/loadFundsFinlyMoney']
  tInitWithdrawFundsFinlyMoney: HandlebarsTemplates['finlyf/settlements/settlement_actions/init/withdrawFundsFinlyMoney']

  templateTransferFlow: HandlebarsTemplates['finlyf/settlements/settlement_actions/init/helpers/transferFlow']

  #Step 2
  tProcessReports: HandlebarsTemplates['finlyf/settlements/settlement_actions/process/reports']

  # Step Final
  tConfirmCreditCash: HandlebarsTemplates['finlyf/settlements/settlement_actions/confirm/creditCash']
  tConfirmDebitCash: HandlebarsTemplates['finlyf/settlements/settlement_actions/confirm/debitCash']
  tConfirmReports: HandlebarsTemplates['finlyf/settlements/settlement_actions/confirm/reports']
  tConfirmMoneyRequests: HandlebarsTemplates['finlyf/settlements/settlement_actions/confirm/moneyRequests']
  tConfirmTransferSummary: HandlebarsTemplates['finlyf/settlements/settlement_actions/confirm/transferSummary']

  events:
    'click .navbar-btn-refresh': 'refetchCollection'
    'click .item': 'showDetails'
    'click .load-more': 'loadMore'
    'click .load-more-users': 'loadMoreUsers'
    'click .filter-status li a': 'filterStatus'

    'click .navbar-menu-li': 'navigate'
    'click .navbar-view-type': 'changeView'

    #Filters
    'click .user': 'userSettlements'
    
    'change input[type=radio][name=advance_request_type]': 'loadRequstedAdvanceList' 

    #settlements
    'click .btn-back-step-2': 'cancelConfirmation'
    'click .settlement-report-select:checkbox': 'processSettlementReport'
    'keyup .search-user': 'prepareSearch'
    'submit .navbar-form': 'cancelEvents'

    #New actions
    'click .btn-summary-action.btn-debit': 'processDebit'
    'click .btn-summary-action.btn-credit': 'processCredit'
    'click input[name=settlement_credit_action]': 'creditDebitOptions'

    #Step 2 Action
    'click .step-1-action': 'settlementActionProcess'
    'click .step-2-action': 'settlementActionFinalize'
    'click .step-final-action': 'settlementActionConfirm'

    #selecting all settlement action items; later report should be changed to item
    'click .settlement-report-select:checkbox': 'processSettlementReport'

    'mouseenter ul.settlement-actions li': 'showActionDefinition'
    'mouseleave ul.settlement-actions li': 'hideActionDefinition'

    #additional events/hacks
    #set height of settlement action definition
    'shown.bs.modal #modal-settlements': 'setHeight'

    #accordion
    'click .panel-heading .row': 'showAccordionBody'

    'click .btn-employee-statement': 'userStatements'

    # Temp Dropdown Filters
    'click .btn-filter': 'filter'

    # New Actions Workflow
    'click .btn-settlement-summary-action': 'processSettlementAction'

    'change input[type=radio].funds-source': 'showBalancePartial'

    'keyup input[type=number].reimbursement-calculation': 'calculateReimbursement'



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
          @params.view_to_load = 'reports'
        
        @collection.url = @collection.url + "/" + @user.toString()
        @collection.fetch({
          reset: true,
          data: _this.params
          success: ->
            _this.populateSummary()

          error: ->
            console.log "Couldn't fetch Successfully."
        })

        # Populating user details in Personal Settlements
        $.ajax({
          url: '/users/' + @user
          dataType: 'json'
          data: {
            view: _this.params.view
          }
          success: (res) ->
            _this.populateUserData(res)
          error: (err) ->
            console.log "Err", err
        })
      else
        @selectedUserSummary = {}
        @settlementActionData = {
          reports: {}
          transfer: {}
          c_cash_advance: {}
          # c_card_from_card: {}
          c_card_from_wallet: {}
          c_wallet_from_wallet: {}
          c_card_from_virtual_account: {}
          c_wallet_from_virtual_account: {}
          d_card_to_card: {}
          d_card_to_wallet: {}
          d_wallet_to_wallet: {}
          d_card_to_company_credits: {}
          d_cash_advance: {}
          d_wallet_to_virtual_account: {}
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
            _this.toggleLoadMoreUsers(_this.collectionUsers)
        })
        @params = options.params
        
    @dump = []
    @dumpUsers = []


    
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
        else if @params.view_to_load == "money_requests"
          $(@el).find(".settlements-index").html(@templateMainMoneyRequests({item: @params}))
        # else if @params.view_to_load == "approved_money_request"
        #   $(@el).find(".settlements-index").html(@templateMainRequestsApproved({item: @params}))
        else if @params.view_to_load == 'reports'
          $(@el).find(".settlements-index").html(@templateMainReports())
        else
          $(@el).find(".settlements-index").html(@templateMainReports())
      else
        $(@el).find(".settlements-index").html(@templateMainReports())

      $(@el).find(".navbar-main").html(@templateNavbarMainPersonal({item: {id: @user}}))
    else
      $(@el).html(@templateSkeletonAdmin({item: @params}))
      $(@el).find('.filter-status li a[data-view=payments]').parent().addClass('active')
      $(@el).find(".settlements-index").html(@templateMainPayments())
      $(@el).find(".navbar-sidebar").html(@templateNavbarSidebar())

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

  loadMoreUsers: (e) ->
    e.preventDefault()
    _this = @
    target = $(e.currentTarget)
    $(target).find('i').removeClass('fa-cloud-download').addClass('fa-spinner fa-pulse')
    $(target).find('span').text('Loading....')
    @params.page = (parseInt($(target).attr("data-page")) || 0 ) + 1

    @collectionUsers.fetch({
      data: _this.params,
      reset: false,
      success: ->
        _this.toggleLoadMore(_this.collectionUsers)
        $(target).find('i').addClass('fa-cloud-download').removeClass('fa-spinner fa-pulse')
        $(target).find('span').text('Load More')
        _this.resetPageCount({target: target, page: _this.params.page })

        _this.dumpUsers = (_this.dumpUsers.concat(_this.collectionUsers.models.slice())).slice()
        _this.collectionUsers.reset(_this.dumpUsers)

      error: ->
        console.log "Couldn't fetch Successfully."
    })

  populateSummary: (id)->
    user_id = id || @user
    # console.log "populating"
    user_model = @collectionUsers.get(user_id)
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
        #Stopping main loader
        summary = $(_this.el).find('.summary')
        FinlyF.stopMainLoader(summary)
        console.log "res", res
        if _this.view == 'personal'
          $(_this.el).find(".summary").html(_this.templateSummary({item: res}))
        else
          $(_this.el).find(".summary").html(_this.templateSummaryAdmin({item: res}))
          _this.selectedUserSummary = res
          _this.selectedUserSummary.user_details = user_model.toJSON()
          # _this.populateBalance()
          # console.log _this.selectedUserSummary
      error: (err) ->
        console.log err

    })

  populateUserData: (item) ->
    $(@el).find(".sidebar").html(@templateSidebarPersonal({item: item}))

  # populateBalance: ->
    #   _this = @
    #   $(@el).find(".user-wallet-balance").closest("li").removeClass("hidden")
    #   $(@el).find(".company-balance").closest("li").removeClass("hidden")
    #   $.ajax({
    #     dataType: "json"
    #     type : 'get'
    #     # url: '/settlements/summary?view_to_load=payments&view=personal'
    #     url: 'users/' + _this.user_id + '/balance'
    #     data:
    #       # target_user_id: user_id
    #       authenticity_token: $("#authenticity_token").val()
    #       current_user_all: true
    #       current_user_wallet: true
    #       current_user_card: true
    #       current_user_cash_in_hand: true
    #       virtual_account: true
    #       # view: 'admin'
    #     success: (data) ->
    #       $(_this).find('.modal-body').html(templateBalance({item: data}))
    #       console.log data
    #     error: (err) ->
    #       console.log err
    #   })

    #   $(@el).find(".user-wallet-balance").text(@selectedUserSummary.current_user_wallet_balance)
    #   $(@el).find(".company-balance").text(@selectedUserSummary.company_credits)

  processUsers: ->
    console.log "processing users"
    @dumpUsers = @collectionUsers.models.slice()
    $(@el).find("#users").html("")

    @collectionUsers.each(@appendUsers, @)

    FinlyF.stopMainLoader()

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
    

    #Stopping main loader
    main = $(@el).find('.settlements-content')
    FinlyF.stopMainLoader(main)

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
      else if view_to_load == "money_requests"
        $(@el).find(".settlements-index").html(@templateMainMoneyRequests({item: {view_to_load: view_to_load}}))#Attention
      # else if view_to_load == "credited_money_request"
      #   $(@el).find(".settlements-index").html(@templateMainRequestsCredited({item: {view_to_load: view_to_load}}))
      else if view_to_load == 'reports'
        $(@el).find(".settlements-index").html(@templateMainReports())#attention
      # console.log @collection.url
      @params.view_to_load = view_to_load
      @collection.fetch({
        data: @params
        reset: true,
        # data: _this.params
        success: ->
          # _this.populateSummary(_this.user_id)

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
    # Show main loader
    settlements_content = $(@el).find(".settlements-content")
    summary = $(@el).find(".summary")
    FinlyF.startMainLoader(settlements_content)
    FinlyF.startMainLoader(summary)
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

    selected_user = @collectionUsers.get(@user_id)
    item = {
      name: selected_user.get('name')
      id: @user_id
      email: selected_user.get('email')
      mobile: selected_user.get('mobile_number')
    }
    $(@el).find(".navbar-main").html(@templateNavbarMain({item: item}))


  userStatements: (e) ->
    e.preventDefault()
    target = e.currentTarget
    user_id = $(target).attr('data-user-id')

    params = {
      view: @params.view
    }

    FinlyF.primary_router.navigate('statements/' + user_id.toString() + '/params=' + JSON.stringify(params), {trigger: true})

  loadRequstedAdvanceList: (e) ->
    _this = @
    # alert("You changed")
    target = e.currentTarget
    modal_body = $(target).closest(".modal-body")
    payment_mode_id = $(modal_body).find("input[type=radio][name=advance_request_type]:checked").val()

    $(modal_body).find('.selected_items_total').text("0")

    items_container = $(modal_body).find('.settlement-action-items')
    $(items_container).html("")

    @params.view_to_load = 'approved_money_request'
    @params.id = @user_id
    # @params.payment_mode_id = payment_mode_id
    # collection = new FinlyF.Collections.Settlements()
    @collectionSettlementReports.each((item) ->
      if parseInt(item.get('payment_mode_id')) == parseInt(payment_mode_id)
        view_item = new FinlyF.Views.Settlement({ model: item, page: 'money_request' })
        $(items_container).append(view_item.render().el)
        # console.log view_item.render
    , @)



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

  processSettlementAction: (e) -> #WHEN CLICKING ON THE SETTLEMENT ACTIONS
    _this = @
    target = e.currentTarget
    action_type = $(target).attr('data-action-type')

    @selectedUserSummary.currentAction = action_type

    console.log "You clicked ", action_type

    modal = $(@el).find("#modal-settlements")
    $(modal).modal('show')

    # console.log "selected user summary", @selectedUserSummary
    $(modal).html(@templateProcessAction({summary: @selectedUserSummary}))

    switch action_type
      # when 'process-reports'
      # when 'process-money-requests'
      # when 'credit-cash'
      # when 'debit-cash'
      # when 'load-funds-card'
      # when 'withdraw-funds-card'
      # when 'load-funds-finlymoney'
      # when 'withdraw-funds-finlymoney'
      when 'process-reports'
        $(modal).find(".settlement-step-1 .panel-heading .step-title .title").text("Select Reports to be Reimbursed")
        $(modal).find(".settlement-step-2 .panel-heading .step-title .title").text("Choose Reimbursement Options")
        #Append base structure
        $(modal).find('.settlement-step-1 .panel-body').html(@tInitReports({summary: @selectedUserSummary}))

        report_container = $(modal).find('.settlement-action-items')
        #Load reports
        @params.view_to_load = 'approved_reports'
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
      when 'process-money-requests'
        $(modal).find(".settlement-step-1 .panel-heading .step-title .title").text("Select Money Requests to Credit")
        $(modal).find(".settlement-step-final .panel-heading .step-title .title").text("Summary & Confirmation")
        #Append base structure
        $(modal).find('.settlement-step-1 .panel-body').html(@tInitMoneyRequests({summary: @selectedUserSummary}))

        items_container = $(modal).find('.settlement-action-items')
        #Load reports
        @params.view_to_load = 'approved_money_requests'
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
              console.log "each money request"
              if item.get('payment_mode') == 'cash'#hard coding for the first time to show cash requested
                view_item = new FinlyF.Views.Settlement({ model: item, page: 'money_request' })
                $(items_container).append(view_item.render().el)
              # view_item = new FinlyF.Views.Settlement({ model: item, page: 'money_request' })
              # $(items_container).append(view_item.render().el)

            , @)

          error: ->
            console.log "Couldn't fetch Successfully."
        })
      when 'credit-cash'
        # console.log "Summary ", @selectedUserSummary
        $(modal).find(".settlement-step-1 .panel-heading .step-title .title").text("Define Amount to Credit")
        $(modal).find(".settlement-step-final .panel-heading .step-title .title").text("Summary & Confirmation")
        #Append base structure
        $(modal).find('.settlement-step-1 .panel-body').html(@tInitCreditCash({summary: @selectedUserSummary}))
      when 'debit-cash'
        $(modal).find(".settlement-step-1 .panel-heading .step-title .title").text("Define Amount to Debit")
        $(modal).find(".settlement-step-final .panel-heading .step-title .title").text("Summary & Confirmation")
        #Append base structure
        $(modal).find('.settlement-step-1 .panel-body').html(@tInitDebitCash({summary: @selectedUserSummary}))
      when 'load-funds-card'
        $(modal).find(".settlement-step-1 .panel-heading .step-title .title").text("Define Amount & Source to Credit")
        $(modal).find(".settlement-step-final .panel-heading .step-title .title").text("Summary & Confirmation")
        #Append base structure
        $(modal).find('.settlement-step-1 .panel-body').html(@tInitLoadFundsCard({summary: @selectedUserSummary}))
      when 'withdraw-funds-card'
        $(modal).find(".settlement-step-1 .panel-heading .step-title .title").text("Define Amount & Source to Debit")
        $(modal).find(".settlement-step-final .panel-heading .step-title .title").text("Summary & Confirmation")
        #Append base structure
        $(modal).find('.settlement-step-1 .panel-body').html(@tInitWithdrawFundsCard({summary: @selectedUserSummary}))
      when 'load-funds-finlymoney'
        $(modal).find(".settlement-step-1 .panel-heading .step-title .title").text("Define Amount & Source to Credit")
        $(modal).find(".settlement-step-final .panel-heading .step-title .title").text("Summary & Confirmation")
        #Append base structure
        $(modal).find('.settlement-step-1 .panel-body').html(@tInitLoadFundsFinlyMoney({summary: @selectedUserSummary}))
      when 'withdraw-funds-finlymoney'
        $(modal).find(".settlement-step-1 .panel-heading .step-title .title").text("Define Amount & Source to Debit")
        $(modal).find(".settlement-step-final .panel-heading .step-title .title").text("Summary & Confirmation")
        #Append base structure
        $(modal).find('.settlement-step-1 .panel-body').html(@tInitWithdrawFundsFinlyMoney({summary: @selectedUserSummary}))
        # ...
      
    


    # #set height of summary
    # meta_data = {
    #   height: 0
    # }

    # container = $(e.currentTarget).closest('.modal-body')
    # $(container).find('.confirmation-screen').css("display", "block")
    # $(container).find('.process-screen').css('display', 'none')

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

    # console.log @selectedReportsTotal()
    total_as_string = Math.round((parseFloat(@selectedReportsTotal())) * 100) / 100
    $(container).closest('.modal-body').find('.selected_items_total').html("&#8377;&nbsp;" + total_as_string.toString())

    #report/moneyrequest names
    @settlementActionData.selectedReportNames = []
    _.each(@settlementActionData.selectedReports, (model) ->
      _this.settlementActionData.selectedReportNames.push(model.get('name'))
    )

    # reports / money request total
    @settlementActionData.selectedReportsTotal = @selectedReportsTotal()

    # console.log "Data is", tempArray

  # showActionDefinition: (e) ->
  #   # console.log "Hovering"
  #   target = e.currentTarget

  #   definition = $(target).find('.action-definition.hidden').html()
  #   div_definition = $(target).closest('.modal-body').find('.settlement-action-definition')

  #   $(div_definition).removeClass('hidden').html(definition) 

  #   # console.log definition

  # hideActionDefinition: (e) ->
  #   target = e.currentTarget
  #   siblings = $(target).closest('ul').find('li')
  #   div_definition = $(target).closest('.modal-body').find('.settlement-action-definition')
  #   definition_type = $(div_definition).attr('data-definition-type')

  #   flag_action_selected = false
  #   for sibling in siblings
  #     if $(sibling).find('input[type=radio]:checked').length > 0
  #       # console.log "Found Checked"
  #       selected_action = sibling
  #       flag_action_selected = true

  #   unless flag_action_selected
  #     if definition_type == 'credit'
  #       $(div_definition).html("<h4 class='text-center'>Transfer Cash to Employee</h4>")
  #     else
  #       $(div_definition).html("<h4 class='text-center'>Withdraw Cash from Employee</h4>")

  #   else
  #     definition = $(selected_action).find('.action-definition.hidden').html()
  #     $(div_definition).html(definition)

  #   # div_definition = $(target).closest('.modal-body').find('.settlement-action-definition')
  #   # $(div_definition).addClass('hidden')

  # processDebit: (e) ->
  #   _this = @
  #   e.preventDefault()
  #   target = e.currentTarget

  #   modal = $(@el).find("#modal-settlements")
  #   $(modal).modal('show')

  #   # console.log "Summary", summary
  #   $(modal).html(@templateProcessDebit({summary: @selectedUserSummary}))

  #   #set height of summary
  #   meta_data = {
  #     height: 0
  #   }
  #   # $(".settlement-action-types").load(->
  #   #   console.log "This is", this
  #   #   meta_data.height = $(this).height()
  #   # )
    
  #   # console.log $(modal).find(".settlement-action-types").height()
  #   # console.log $(modal).find(".settlement-action-types").html()
  #   # $(modal).find(".settlement-action-definition").height(meta_data.height)

  # processCredit: (e) ->
  #   e.preventDefault()
  #   target = e.currentTarget

  #   modal = $(@el).find("#modal-settlements")
  #   $(modal).modal('show')

  #   # console.log "Summary", @selectedUserSummary
  #   $(modal).html(@templateProcessCredit({summary: @selectedUserSummary}))

  # setHeight: (e) ->
  #   target = e.currentTarget

  #   setTimeout(->
  #     console.log "height", $(target).find(".settlement-action-types ul.settlement-actions").height()
  #     $(target).find(".settlement-action-definition").height($(target).find(".settlement-action-types ul.settlement-actions").height() - 20)
  #   ,1)

  showAccordionBody: (e) ->
    target = e.currentTarget
    target_panel = $(target).closest('.panel')
    # activated = undefined

    unless $(target_panel).hasClass('active')
      #if navigate is true open current collapse
      if parseInt($(target_panel).attr('data-navigate'))
        $(target_panel).find('.panel-collapse').collapse('show')
        $(target_panel).addClass('active')
        activated = parseInt($(target_panel).attr('data-step'))


        sibling_panels = $(target_panel).siblings(".panel")
        for sibling_panel in sibling_panels
          $(sibling_panel).find('.panel-collapse').collapse('hide')
          $(sibling_panel).removeClass('active')
          if parseInt($(sibling_panel).attr('data-step')) > activated
            $(sibling_panel).attr('data-navigate', 0)

    # panels = $(target).closest('.panel-group').find('.panel')
    # for panel in panels
    #   if $(panel).hasClass('active')
    #     active = parseInt($(panel).attr('data-step'))

    # for 



    # for panel in panels
    #   $(panel).removeClass('active')

    # panel = $(target).closest('.panel')
    # $(panel).addClass('active')

  # creditDebitOptions: (e) ->
  #   _this = @
  #   target = e.currentTarget
  #   action_type = $(target).attr('data-action-type')

  #   # adding active clss and removing
  #   lis = $(target).closest('ul').find('li')
  #   for li in lis
  #     $(li).removeClass('active')

  #   $(target).closest('li').addClass('active')

  #   definition = $(target).find('.action-definition.hidden').html()
  #   div_definition = $(target).closest('.modal-body').find('.settlement-action-definition')

  #   $(div_definition).html(definition) 


  #   modal_body = $(target).closest('.modal-body')
  #   $(modal_body).find('#collapse-step-1').collapse('hide')
  #   $(modal_body).find('#collapse-step-2').collapse('show')

  #   $(modal_body).find(".settlement-step-1").removeClass('active')
  #   $(modal_body).find(".settlement-step-2").addClass('active').attr('data-navigate', '1')
  #   $(modal_body).find(".settlement-step-2 .panel-heading .step-heading-summary").html("")

  #   switch action_type
  #     when 'credit_reimbursement'
        
  #       $(modal_body).find(".settlement-step-1 .panel-heading .step-title .title").text("Type: Credit Reimbursement")
  #       $(modal_body).find(".settlement-step-2 .panel-heading .step-title .title").text("Select Reports to be Reimbursed")
  #       #Append base structure
  #       $(modal_body).find('.settlement-step-2 .panel-body').html(@tCreditReimburse({summary: @selectedUserSummary}))

  #       report_container = $(modal_body).find('.settlement-action-items')
  #       #Load reports
  #       @params.view_to_load = 'approved_reports'
  #       @params.id = @user_id
  #       # collection = new FinlyF.Collections.Settlements()
  #       @collectionSettlementReports.url = "/settlements/" + @user_id
  #       @collectionSettlementReports.fetch({
  #         data: @params
  #         reset: true,
  #         data: _this.params
  #         success: ->
  #           _this.collectionSettlementReports.each((item) ->
  #             view_item = new FinlyF.Views.Settlement({ model: item, page: 'reimburse' })
  #             $(report_container).append(view_item.render().el)
  #           , @)

  #         error: ->
  #           console.log "Couldn't fetch Successfully."
  #       })

  #     # when 'credit_settle', 'debit_settle'
  #       # $(modal_body).find(".settlement-step-1 .panel-heading .step-title .title").text("Type: Credit & Settle")
  #       # $(modal_body).find(".settlement-step-2 .panel-heading .step-title .title").text("Select Reports to ")
  #       # #Append base structure
  #       # $(modal_body).find('.settlement-step-2 .panel-body').html(@templateBaseSettlement({summary: @selectedUserSummary}))

  #       # report_container = $(modal_body).find('.settlement-action-items')
  #       # #Load reports
  #       # @params.view_to_load = 'approved'
  #       # @params.id = @user_id
  #       # # collection = new FinlyF.Collections.Settlements()
  #       # @collectionSettlementReports.url = "/settlements/" + @user_id
  #       # @collectionSettlementReports.fetch({
  #       #   data: @params
  #       #   reset: true,
  #       #   data: _this.params
  #       #   success: ->
  #       #     _this.collectionSettlementReports.each((item) ->
  #       #       view_item = new FinlyF.Views.Settlement({ model: item, page: 'reimburse' })
  #       #       $(report_container).append(view_item.render().el)
  #       #     , @)

  #       #   error: ->
  #       #     console.log "Couldn't fetch Successfully."
  #       # })

  #     when 'credit_cash_advance'
  #       $(modal_body).find(".settlement-step-1 .panel-heading .step-title .title").text("Type: Add Cash Advance")
  #       $(modal_body).find(".settlement-step-2 .panel-heading .step-title .title").text("Input Amount to be Credited")
  #       #Append base structure
  #       $(modal_body).find('.settlement-step-2 .panel-body').html(@tCreditCashAdvance({summary: @selectedUserSummary}))
  #     when 'credit_money_request'#advance funds request
  #       $(modal_body).find(".settlement-step-1 .panel-heading .step-title .title").text("Type: Credit Advance Requests")
  #       $(modal_body).find(".settlement-step-2 .panel-heading .step-title .title").text("Select Pending Advanced Requests to be Credited")
  #       #Append base structure
  #       $(modal_body).find('.settlement-step-2 .panel-body').html(@tCreditMoneyRequest({summary: @selectedUserSummary}))

  #       items_container = $(modal_body).find('.settlement-action-items')
  #       #Load reports
  #       @params.view_to_load = 'approved_money_requests'
  #       @params.id = @user_id

  #       # @params.payment_mode_id = 1
  #       # collection = new FinlyF.Collections.Settlements()
  #       @collectionSettlementReports.url = "/settlements/" + @user_id
  #       @collectionSettlementReports.fetch({
  #         data: @params
  #         reset: true,
  #         data: _this.params
  #         success: ->
  #           _this.collectionSettlementReports.each((item) ->
  #             console.log "each money request"
  #             if item.get('payment_mode') == 'cash'#hard coding for the first time to show cash requested
  #               view_item = new FinlyF.Views.Settlement({ model: item, page: 'money_request' })
  #               $(items_container).append(view_item.render().el)
  #             # view_item = new FinlyF.Views.Settlement({ model: item, page: 'money_request' })
  #             # $(items_container).append(view_item.render().el)

  #           , @)

  #         error: ->
  #           console.log "Couldn't fetch Successfully."
  #       })
  #     when 'credit_card_from_card'
  #       $(modal_body).find(".settlement-step-1 .panel-heading .step-title .title").text("Type: Credit from Your Card")
  #       $(modal_body).find(".settlement-step-2 .panel-heading .step-title .title").text("Input Amount to be Credited from Your Card")
  #       # console.log "Credit card from card" 
  #       $(modal_body).find('.settlement-step-2 .panel-body').html(@tCreditCardFromCard({summary: @selectedUserSummary}))
  #     when 'credit_card_from_wallet'
  #       console.log @selectedUserSummary
  #       $(modal_body).find(".settlement-step-1 .panel-heading .step-title .title").text("Type: Credit from Your Finly Account")
  #       $(modal_body).find(".settlement-step-2 .panel-heading .step-title .title").text("Input Amount to be Credited from Your Finly Account")
  #       $(modal_body).find('.settlement-step-2 .panel-body').html(@tCreditCardFromWallet({summary: @selectedUserSummary}))
  #       $.ajax({
  #         url: 'users/' + _this.user_id + '/balance'
  #         data: {
  #           view: _this.params.view
  #           target_user_card: true
  #           current_user_wallet: true
  #         }
  #         type: 'get',
  #         dataType: 'json'
  #         success: (res) ->
  #           console.log res
  #           $(modal_body).find('.settlement-step-2 .current_user_wallet_balance').html("&#8377;&nbsp;" + res.current_user_wallet)
  #           $(modal_body).find('.settlement-step-2 .target_user_card_balance').html("&#8377;&nbsp;" + res.target_user_card)
  #       })
  #     when 'credit_wallet_from_wallet'
  #       $(modal_body).find(".settlement-step-1 .panel-heading .step-title .title").text("Type: Credit from Your Finly Account")
  #       $(modal_body).find(".settlement-step-2 .panel-heading .step-title .title").text("Input Amount to be Credited from Your Finly Account")
  #       $(modal_body).find('.settlement-step-2 .panel-body').html(@tCreditWalletFromWallet({summary: @selectedUserSummary}))
  #       $.ajax({
  #         url: 'users/' + _this.user_id + '/balance'
  #         data: {
  #           view: _this.params.view
  #           target_user_wallet: true
  #           current_user_wallet: true
  #         }
  #         type: 'get',
  #         dataType: 'json'
  #         success: (res) ->
  #           console.log res
  #           $(modal_body).find('.settlement-step-2 .current_user_wallet_balance').html("&#8377;&nbsp;" + res.current_user_wallet)
  #           $(modal_body).find('.settlement-step-2 .target_user_wallet_balance').html("&#8377;&nbsp;" + res.target_user_wallet)
  #       })
  #     when 'credit_card_from_virtual_account'
  #       console.log @selectedUserSummary
  #       $(modal_body).find(".settlement-step-1 .panel-heading .step-title .title").text("Type: Credit from Company Credits")
  #       $(modal_body).find(".settlement-step-2 .panel-heading .step-title .title").text("Input Amount to be Credited from Your Company Balance")
  #       $(modal_body).find('.settlement-step-2 .panel-body').html(@tCreditCardFromVirtualAccount({summary: @selectedUserSummary}))
  #       $.ajax({
  #         url: 'users/' + _this.user_id + '/balance'
  #         data: {
  #           view: _this.params.view
  #           target_user_card: true
  #           virtual_account: true
  #         }
  #         type: 'get',
  #         dataType: 'json'
  #         success: (res) ->
  #           # console.log res
  #           $(modal_body).find('.settlement-step-2 .virtual_account_balance').html("&#8377;&nbsp;" + res.virtual_account)
  #           $(modal_body).find('.settlement-step-2 .target_user_card_balance').html("&#8377;&nbsp;" + res.target_user_card)
  #       })
  #     when 'credit_wallet_from_virtual_account'
  #       $(modal_body).find(".settlement-step-1 .panel-heading .step-title .title").text("Type: Credit Finly Account from Company Credits")
  #       $(modal_body).find(".settlement-step-2 .panel-heading .step-title .title").text("Input Amount to be Credited from Your Company Balance")
  #       $(modal_body).find('.settlement-step-2 .panel-body').html(@tCreditWalletFromVirtualAccount({summary: @selectedUserSummary}))
  #       $.ajax({
  #         url: 'users/' + _this.user_id + '/balance'
  #         data: {
  #           view: _this.params.view
  #           target_user_wallet: true
  #           virtual_account: true
  #         }
  #         type: 'get',
  #         dataType: 'json'
  #         success: (res) ->
  #           # console.log res
  #           $(modal_body).find('.settlement-step-2 .virtual_account_balance').html("&#8377;&nbsp;" + res.virtual_account)
  #           $(modal_body).find('.settlement-step-2 .target_user_wallet_balance').html("&#8377;&nbsp;" + res.target_user_wallet)
  #       })
  #     #DEBIT ACTIONS
  #     when 'debit_cash_advance'
  #       $(modal_body).find(".settlement-step-1 .panel-heading .step-title .title").text("Type: Debit Cash Advance")
  #       $(modal_body).find(".settlement-step-2 .panel-heading .step-title .title").text("Input Amount to be Debited from Employee's Cash in Hand")
  #       #Append base structure
  #       $(modal_body).find('.settlement-step-2 .panel-body').html(@tDebitCashAdvance({summary: @selectedUserSummary}))
  #     when 'debit_card_to_card' 
  #       $(modal_body).find(".settlement-step-1 .panel-heading .step-title .title").text("Type: Debit Balance to Your Card")
  #       $(modal_body).find(".settlement-step-2 .panel-heading .step-title .title").text("Input Amount to be Debited from Employee's Card to Your Card")
  #       $(modal_body).find('.settlement-step-2 .panel-body').html(@tDebitCardToCard({summary: @selectedUserSummary}))
  #     when 'debit_card_to_wallet'
  #       $(modal_body).find(".settlement-step-1 .panel-heading .step-title .title").text("Type: Debit Balance to Your Finly Account")
  #       $(modal_body).find(".settlement-step-2 .panel-heading .step-title .title").text("Input Amount to be Debited from Employee's Card to Your Finly Account")
  #       $(modal_body).find('.settlement-step-2 .panel-body').html(@tDebitCardToWallet({summary: @selectedUserSummary}))
        
  #     when 'debit_wallet_to_wallet'
  #       $(modal_body).find(".settlement-step-1 .panel-heading .step-title .title").text("Type: Debit Balance to Your Finly Account")
  #       $(modal_body).find(".settlement-step-2 .panel-heading .step-title .title").text("Input Amount to be Debited from Employee's Card to Your Finly Account")
  #       $(modal_body).find('.settlement-step-2 .panel-body').html(@tDebitWalletToWallet({summary: @selectedUserSummary}))
  #       $.ajax({
  #         url: 'users/' + _this.user_id + '/balance'
  #         data: {
  #           view: _this.params.view
  #           target_user_wallet: true
  #           current_user_wallet: true
  #         }
  #         type: 'get',
  #         dataType: 'json'
  #         success: (res) ->
  #           # console.log res
  #           $(modal_body).find('.settlement-step-2 .current_user_wallet_balance').html("&#8377;&nbsp;" + res.current_user_wallet)
  #           $(modal_body).find('.settlement-step-2 .target_user_wallet_balance').html("&#8377;&nbsp;" + res.target_user_wallet)
  #       })
  #     when 'debit_wallet_to_virtual_account' 
  #       $(modal_body).find(".settlement-step-1 .panel-heading .step-title .title").text("Type: Debit Balance to Company Credits")
  #       $(modal_body).find(".settlement-step-2 .panel-heading .step-title .title").text("Input Amount to be Debited from Employee's Card to Company Balance")
  #       $(modal_body).find('.settlement-step-2 .panel-body').html(@tDebitWalletToVirtualAccount({summary: @selectedUserSummary}))
  #       $.ajax({
  #         url: 'users/' + _this.user_id + '/balance'
  #         data: {
  #           view: _this.params.view
  #           target_user_wallet: true
  #           virtual_account: true
  #         }
  #         type: 'get',
  #         dataType: 'json'
  #         success: (res) ->
  #           # console.log res
  #           $(modal_body).find('.settlement-step-2 .virtual_account_balance').html("&#8377;&nbsp;" + res.virtual_account)
  #           $(modal_body).find('.settlement-step-2 .target_user_wallet_balance').html("&#8377;&nbsp;" + res.target_user_wallet)
  #       })
  #   $(modal_body).find(".datepicker").datepicker({dateFormat: "dd-mm-yy"})


  settlementActionProcess: (e) ->#Step one action
    e.preventDefault()
    _this = @
    target = e.currentTarget

    action_type = $(target).attr('data-action-type')
    action_url = $(target).attr('data-url')
    modal_body = $(target).closest('.modal-body')
    container = $(target).closest("#collapse-step-1")
    $(modal_body).find('#collapse-step-2').collapse('hide')
    $(modal_body).find('#collapse-step-3').collapse('show')


    $(modal_body).find(".settlement-step-2").removeClass('active')
    $(modal_body).find(".settlement-step-3").addClass('active').attr('data-navigate', '1')
    $(modal_body).find(".settlement-step-2 .panel-heading .step-heading-summary").html("")

    summary = {}

    if action_type == 'credit_reimbursement'
      $(modal_body).find('#collapse-step-1').collapse('hide')
      $(modal_body).find('#collapse-step-2').collapse('show')

      $(modal_body).find(".settlement-step-1").removeClass('active')
      $(modal_body).find(".settlement-step-2").addClass('active').attr('data-navigate', '1')
    else
      $(modal_body).find('#collapse-step-1').collapse('hide')
      $(modal_body).find('#collapse-step-final').collapse('show')

      $(modal_body).find(".settlement-step-1").removeClass('active')
      $(modal_body).find(".settlement-step-final").addClass('active').attr('data-navigate', '1')


    switch action_type
      when 'credit_reimbursement'
        summary.userData = @selectedUserSummary
        summary.actionData = @settlementActionData
        $(modal_body).find(".settlement-step-2 .panel-body").html(@tProcessReports({summary: summary}))

      when 'credit_money_request'
        summary.userData = @selectedUserSummary
        summary.actionData = @settlementActionData
        $(modal_body).find(".settlement-step-final .panel-body").html(@tConfirmMoneyRequests({summary: summary}))
      when 'credit_cash_advance'
        # console.log "I'm good. how are you?"
        _this.settlementActionData.c_cash_advance.amount = $(container).find('input[name=payment\\[amount\\]]').val()
        # _this.settlementActionData.c_cash_advance.date = $(container).find('input[name=payment\\[date\\]]').val()
        # _this.settlementActionData.c_cash_advance.note = $(container).find('textarea[name=payment\\[note\\]]').val()

        summary.userData = @selectedUserSummary
        summary.actionData = @settlementActionData
        console.log "summary", summary
        $(modal_body).find(".settlement-step-final .panel-body").html(@tConfirmCreditCash({summary: summary}))
      when 'debit_cash_advance'
        _this.settlementActionData.d_cash_advance.amount = $(container).find('input[name=payment\\[amount\\]]').val()

        summary.userData = @selectedUserSummary
        summary.actionData = @settlementActionData
        $(modal_body).find(".settlement-step-final .panel-body").html(@tConfirmDebitCash({summary: summary}))
      when 'credit_card_from_wallet'
        _this.settlementActionData.transfer.amount = $(modal_body).find('input[name=amount]').val()
        _this.settlementActionData.transfer.to = @selectedUserSummary.user_details.name + "'s Card"
        _this.settlementActionData.transfer.from = "Your Finly Money"
        _this.settlementActionData.transfer.receiver = @selectedUserSummary.user_details.name
        _this.settlementActionData.transfer.to_user_id = @selectedUserSummary.user_details.id
        _this.settlementActionData.transfer.from_user_id = (->)()

        _this.settlementActionData.transfer.current_action = action_type
        _this.settlementActionData.transfer.current_url = action_url


        summary.userData = @selectedUserSummary
        summary.actionData = @settlementActionData
        $(modal_body).find('.settlement-step-final .panel-body').html(@tConfirmTransferSummary({summary: summary}))
      when 'credit_card_from_virtual_account'
        _this.settlementActionData.transfer.amount = $(modal_body).find('input[name=amount]').val()
        _this.settlementActionData.transfer.to = @selectedUserSummary.user_details.name + "'s Card"
        _this.settlementActionData.transfer.from = "Company Balance"
        _this.settlementActionData.transfer.receiver = @selectedUserSummary.user_details.name
        _this.settlementActionData.transfer.to_user_id = @selectedUserSummary.user_details.id
        _this.settlementActionData.transfer.from_user_id = (->)()

        _this.settlementActionData.transfer.current_action = action_type
        _this.settlementActionData.transfer.current_url = action_url

        summary.userData = @selectedUserSummary
        summary.actionData = @settlementActionData
        $(modal_body).find('.settlement-step-final .panel-body').html(@tConfirmTransferSummary({summary: summary}))
      when 'credit_card_from_card'
        _this.settlementActionData.transfer.amount = $(modal_body).find('input[name=amount]').val()
        _this.settlementActionData.transfer.to = @selectedUserSummary.user_details.name + "'s Card"
        _this.settlementActionData.transfer.from = "Your Card"
        _this.settlementActionData.transfer.receiver = @selectedUserSummary.user_details.name

        _this.settlementActionData.transfer.to_user_id = @selectedUserSummary.user_details.id
        _this.settlementActionData.transfer.from_user_id = (->)()

        _this.settlementActionData.transfer.current_action = action_type
        _this.settlementActionData.transfer.current_url = action_url

        summary.userData = @selectedUserSummary
        summary.actionData = @settlementActionData
        $(modal_body).find('.settlement-step-final .panel-body').html(@tConfirmTransferSummary({summary: summary}))
      when 'debit_card_to_wallet'
        _this.settlementActionData.transfer.amount = $(modal_body).find('input[name=amount]').val()
        _this.settlementActionData.transfer.to = "Your Finly Money"
        _this.settlementActionData.transfer.from = @selectedUserSummary.user_details.name + "'s Card"
        _this.settlementActionData.transfer.receiver = "You"

        _this.settlementActionData.transfer.to_user_id = (->)()
        _this.settlementActionData.transfer.from_user_id = @selectedUserSummary.user_details.id

        _this.settlementActionData.transfer.current_action = action_type
        _this.settlementActionData.transfer.current_url = action_url

        summary.userData = @selectedUserSummary
        summary.actionData = @settlementActionData
        $(modal_body).find('.settlement-step-final .panel-body').html(@tConfirmTransferSummary({summary: summary}))
      when 'debit_card_to_card'
        _this.settlementActionData.transfer.amount = $(modal_body).find('input[name=amount]').val()
        _this.settlementActionData.transfer.to = "Your Card"
        _this.settlementActionData.transfer.from = @selectedUserSummary.user_details.name + "'s Card"
        _this.settlementActionData.transfer.receiver = "You"

        _this.settlementActionData.transfer.to_user_id = (->)()
        _this.settlementActionData.transfer.from_user_id = @selectedUserSummary.user_details.id

        _this.settlementActionData.transfer.current_action = action_type
        _this.settlementActionData.transfer.current_url = action_url

        summary.userData = @selectedUserSummary
        summary.actionData = @settlementActionData
        $(modal_body).find('.settlement-step-final .panel-body').html(@tConfirmTransferSummary({summary: summary}))
      when 'debit_card_to_virtual_account'
        _this.settlementActionData.transfer.amount = $(modal_body).find('input[name=amount]').val()
        _this.settlementActionData.transfer.to = "Company Balance"
        _this.settlementActionData.transfer.from = @selectedUserSummary.user_details.name + "'s Card"
        _this.settlementActionData.transfer.receiver = "Company"

        _this.settlementActionData.transfer.to_user_id = (->)()
        _this.settlementActionData.transfer.from_user_id = @selectedUserSummary.user_details.id

        _this.settlementActionData.transfer.current_action = action_type
        _this.settlementActionData.transfer.current_url = action_url

        summary.userData = @selectedUserSummary
        summary.actionData = @settlementActionData
        $(modal_body).find('.settlement-step-final .panel-body').html(@tConfirmTransferSummary({summary: summary}))
      when 'credit_wallet_from_wallet'
        _this.settlementActionData.transfer.amount = $(modal_body).find('input[name=amount]').val()
        _this.settlementActionData.transfer.to = @selectedUserSummary.user_details.name + "'s Finly Money"
        _this.settlementActionData.transfer.from = "Your Finly Money"
        _this.settlementActionData.transfer.receiver = @selectedUserSummary.user_details.name

        _this.settlementActionData.transfer.to_user_id = @selectedUserSummary.user_details.id
        _this.settlementActionData.transfer.from_user_id = (->)()

        _this.settlementActionData.transfer.current_action = action_type
        _this.settlementActionData.transfer.current_url = action_url

        summary.userData = @selectedUserSummary
        summary.actionData = @settlementActionData
        $(modal_body).find('.settlement-step-final .panel-body').html(@tConfirmTransferSummary({summary: summary}))
      when 'credit_wallet_from_card'
        _this.settlementActionData.transfer.amount = $(modal_body).find('input[name=amount]').val()
        _this.settlementActionData.transfer.to = @selectedUserSummary.user_details.name + "'s Finly Money"
        _this.settlementActionData.transfer.from = "Your Card"
        _this.settlementActionData.transfer.receiver = @selectedUserSummary.user_details.name

        _this.settlementActionData.transfer.to_user_id = @selectedUserSummary.user_details.id
        _this.settlementActionData.transfer.from_user_id = (->)()

        _this.settlementActionData.transfer.current_action = action_type
        _this.settlementActionData.transfer.current_url = action_url

        summary.userData = @selectedUserSummary
        summary.actionData = @settlementActionData
        $(modal_body).find('.settlement-step-final .panel-body').html(@tConfirmTransferSummary({summary: summary}))
      when 'credit_wallet_from_virtual_account'
        _this.settlementActionData.transfer.amount = $(modal_body).find('input[name=amount]').val()
        _this.settlementActionData.transfer.to = @selectedUserSummary.user_details.name + "'s Finly Money"
        _this.settlementActionData.transfer.from = "Company Balance"
        _this.settlementActionData.transfer.receiver = @selectedUserSummary.user_details.name

        _this.settlementActionData.transfer.to_user_id = @selectedUserSummary.user_details.id
        _this.settlementActionData.transfer.from_user_id = (->)()

        _this.settlementActionData.transfer.current_action = action_type
        _this.settlementActionData.transfer.current_url = action_url

        summary.userData = @selectedUserSummary
        summary.actionData = @settlementActionData
        $(modal_body).find('.settlement-step-final .panel-body').html(@tConfirmTransferSummary({summary: summary}))
      when 'debit_wallet_to_wallet'
        _this.settlementActionData.transfer.amount = $(modal_body).find('input[name=amount]').val()
        _this.settlementActionData.transfer.to = "Your Finly Money"
        _this.settlementActionData.transfer.from = @selectedUserSummary.user_details.name + "'s Finly Money"
        _this.settlementActionData.transfer.receiver = "You"

        _this.settlementActionData.transfer.to_user_id = (->)()
        _this.settlementActionData.transfer.from_user_id = @selectedUserSummary.user_details.id

        _this.settlementActionData.transfer.current_action = action_type
        _this.settlementActionData.transfer.current_url = action_url

        summary.userData = @selectedUserSummary
        summary.actionData = @settlementActionData
        $(modal_body).find('.settlement-step-final .panel-body').html(@tConfirmTransferSummary({summary: summary}))
      when 'debit_wallet_to_card'
        _this.settlementActionData.transfer.amount = $(modal_body).find('input[name=amount]').val()
        _this.settlementActionData.transfer.to = "Your Card"
        _this.settlementActionData.transfer.from = @selectedUserSummary.user_details.name + "'s Finly Money"
        _this.settlementActionData.transfer.receiver = "You"

        _this.settlementActionData.transfer.to_user_id = (->)()
        _this.settlementActionData.transfer.from_user_id = @selectedUserSummary.user_details.id

        _this.settlementActionData.transfer.current_action = action_type
        _this.settlementActionData.transfer.current_url = action_url

        summary.userData = @selectedUserSummary
        summary.actionData = @settlementActionData
        $(modal_body).find('.settlement-step-final .panel-body').html(@tConfirmTransferSummary({summary: summary}))
      when 'debit_wallet_to_virtual_account'
        _this.settlementActionData.transfer.amount = $(modal_body).find('input[name=amount]').val()
        _this.settlementActionData.transfer.to = "Company Balance"
        _this.settlementActionData.transfer.from = @selectedUserSummary.user_details.name + "'s Finly Money"
        _this.settlementActionData.transfer.receiver = "Company"

        _this.settlementActionData.transfer.to_user_id = (->)()
        _this.settlementActionData.transfer.from_user_id = @selectedUserSummary.user_details.id

        _this.settlementActionData.transfer.current_action = action_type
        _this.settlementActionData.transfer.current_url = action_url  

        summary.userData = @selectedUserSummary
        summary.actionData = @settlementActionData
        $(modal_body).find('.settlement-step-final .panel-body').html(@tConfirmTransferSummary({summary: summary}))

    $(modal_body).find(".datepicker").datepicker({dateFormat: "dd-mm-yy"})
        

  settlementActionFinalize: (e) ->#Step 2 Action
    # console.log "Hello there!"
    e.preventDefault()
    _this = @
    target = e.currentTarget

    action_type = $(target).attr('data-action-type')
    modal_body = $(target).closest('.modal-body')
    container = $(target).closest("#collapse-step-2")
    $(modal_body).find('#collapse-step-2').collapse('hide')
    $(modal_body).find('#collapse-step-final').collapse('show')


    $(modal_body).find(".settlement-step-2").removeClass('active')
    $(modal_body).find(".settlement-step-final").addClass('active').attr('data-navigate', '1')
    # $(modal_body).find(".settlement-step-2 .panel-heading .step-heading-summary").html("")

    summary = {}
    switch action_type
      when 'credit_reimbursement'
        console.log "Atleast coming hre!"
        #Setup and how colapse 3
        # $(modal_body).find(".settlement-step-final .panel-heading .step-title .title").text("Additional Note")
        @settlementActionData.reports.from_cash_in_hand = $(modal_body).find('input[name=from_cash_in_hand]').val()
        @settlementActionData.reports.from_outside_finly = $(modal_body).find('input[name=from_outside_finly]').val()
        #Append base structure
        summary.userData = @selectedUserSummary
        summary.actionData = @settlementActionData
        $(modal_body).find('.settlement-step-final .panel-body').html(@tConfirmReports({summary: summary}))

    
    $(modal_body).find(".datepicker").datepicker({dateFormat: "dd-mm-yy"})

  settlementActionConfirm: (e) -> #Step Final Action
    e.preventDefault()
    _this = @
    target = e.currentTarget
    $(target).attr("disabled", true)

    action_type = $(target).attr('data-action-type')
    modal_body = $(target).closest('.modal-body')
    # $(modal_body).find('#collapse-step-2').collapse('hide')
    # $(modal_body).find('#collapse-step-3').collapse('show')

    container = $(target).closest('#collapse-step-final')

    url = $(target).attr('data-url')
    data = {}
    data.view = _this.params.view
    data.authenticity_token = $("#authenticity_token").val()
    # console.log action_type

    switch action_type
      when 'credit_reimbursement'
        # console.log "Selected data",_this.settlementActionData
        # data.report_ids = _this.settlementActionData.selected.slice()
        data.report_ids = _this.settlementActionData.selected.slice()
        data.payment = {
          note: $(container).find('textarea[name=payment\\[note\\]]').val()
          date: $(container).find('input[name=payment\\[date\\]]').val()
          amount: parseFloat(_this.selectedReportsTotal())
          from_cash_in_hand: _this.settlementActionData.reports.from_cash_in_hand
          from_outside_finly: _this.settlementActionData.reports.from_outside_finly
        }
        data.password = $(container).find('input[type=password][name=password]').val()
      when 'credit_money_request'
        data.money_request_ids = _this.settlementActionData.selected.slice()
        data.payment = {
          note: $(container).find('textarea[name=payment\\[note\\]]').val()
          date: $(container).find('input[name=payment\\[date\\]]').val()
          amount: parseFloat(_this.selectedReportsTotal())
        }
        data.password = $(container).find('input[type=password][name=password]').val()
      when 'credit_cash_advance'
        data.payment = {
          amount: _this.settlementActionData.c_cash_advance.amount
          date: $(container).find('input[name=date]').val()
          note: $(container).find('textarea[name=note]').val()
        }
        data.password = $(container).find('input[type=password][name=password]').val()
      when 'debit_cash_advance'
        data.payment = {
          amount: _this.settlementActionData.d_cash_advance.amount
          date: $(container).find('input[name=date]').val()
          note: $(container).find('textarea[name=note]').val()
        }
        data.password = $(container).find('input[type=password][name=password]').val()
      when 'transfer'
        data.amount = _this.settlementActionData.transfer.amount
        data.password = $(container).find('input[type=password][name=password]').val()
        data.note = $(container).find('textarea[name=note]').val()
        data.date = $(container).find('input[name=date]').val()
        data.to_user_id = _this.settlementActionData.transfer.to_user_id
        data.from_user_id = _this.settlementActionData.transfer.from_user_id

    summary = $(@el).find(".summary")
    $.ajax({
      url: url,
      data: data,
      type: "POST",
      dataType: 'json',
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          FinlyF.startMainLoader(summary)
          # console.log "Shouldn't get inside."
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
        else
          $(target).attr('disabled', false)
      error: (err) ->
        console.log "err", err
        $(target).attr('disabled', false)
    })



  # confirmAction: (e) ->
  #   # @settlementActionData = {}
  #   e.preventDefault()
  #   _this = @
  #   target = e.currentTarget

  #   action_type = $(target).attr('data-action-type')
  #   modal_body = $(target).closest('.modal-body')
  #   container = $(target).closest("#collapse-step-final")
  #   $(modal_body).find('#collapse-step-2').collapse('hide')
  #   $(modal_body).find('#collapse-step-final').collapse('show')


  #   $(modal_body).find(".settlement-step-2").removeClass('active')
  #   $(modal_body).find(".settlement-step-final").addClass('active').attr('data-navigate', '1')
  #   # $(modal_body).find(".settlement-step-2 .panel-heading .step-heading-summary").html("")

  #   summary = {}
  #   switch action_type
  #     when 'credit_reimbursement'
  #       #Setup and how colapse 3
  #       # $(modal_body).find(".settlement-step-3 .panel-heading .step-title .title").text("Additional Note")
  #       #Append base structure
  #       summary.userData = @selectedUserSummary
  #       summary.actionData = @settlementActionData
  #       $(modal_body).find('.settlement-step-final .panel-body').html(@tCreditReimburseConfirm({summary: summary}))

  #       # $(modal_body).find(".settlement-step-2 .panel-heading .step-heading-summary").html("Total: &#8377;&nbsp;" + _this.settlementActionData.c_cash_advance.amount)
  #       #Collect relevant data from Step 2
  #       # container = $(e.currentTarget).closest('.settlement-action-items')
  #       # reports =  $(container).find('.settlement-report')
  #       # flag = false
  #       # _this.settlementActionData.selected = []
  #       # for report in reports
  #       #   if $(report).find('.settlement-report-select:checkbox').prop('checked')
  #       #     # flag = true
  #       #     console.log "Found one"
  #       #     _this.settlementActionData.selected.push parseInt($(report).find('.settlement-report-select:checkbox').attr('data-item-id'))
  #           # return
  #       # if flag == true
  #       #   $(container).closest('.modal-body').find('.btn-settlement-action').prop('disabled', false)
  #       # else
  #       #   $(container).closest('.modal-body').find('.btn-settlement-action').prop('disabled', true)

  #       # @selectedReports = _.select(@collectionSettlementReports.models, (model) ->
  #       #   (_.indexOf(_this.selected, model.get('id')) > -1)
  #       # )
  #       # $(container).closest('.modal-body').find('.selected_items_total').text(@selectedReportsTotal())

  #     when 'credit_cash_advance'
  #       $(modal_body).find(".settlement-step-3 .panel-heading .step-title .title").text("Authorize Payment")

  #       #Append base structure
  #       _this.settlementActionData.c_cash_advance.amount = $(container).find('input[name=payment\\[amount\\]]').val()
  #       _this.settlementActionData.c_cash_advance.date = $(container).find('input[name=payment\\[date\\]]').val()
  #       _this.settlementActionData.c_cash_advance.note = $(container).find('textarea[name=payment\\[note\\]]').val()

  #       summary.userData = @selectedUserSummary
  #       summary.actionData = @settlementActionData
  #       $(modal_body).find(".settlement-step-2 .panel-heading .step-heading-summary").html("Total: &#8377;&nbsp;" + _this.settlementActionData.c_cash_advance.amount)

  #       $(modal_body).find('.settlement-step-3 .panel-body').html(@tCreditCashAdvanceConfirm({summary: summary}))
  #     when 'credit_money_request'
  #       $(modal_body).find(".settlement-step-3 .panel-heading .step-title .title").text("Authorize Payment")
  #       summary.userData = @selectedUserSummary
  #       summary.actionData = @settlementActionData

  #       $(modal_body).find('.settlement-step-3 .panel-body').html(@tCreditMoneyRequestConfirm({summary: summary}))

  #     ## Temporarily Disabled
  #     # when 'credit_card_from_card'
  #     #   $(modal_body).find(".settlement-step-3 .panel-heading .step-title .title").text("Authorize Payment")
  #     #   _this.settlementActionData.c_card_from_card.amount = $(container).find('input[name=amount]').val()

  #     #   summary.userData = @selectedUserSummary
  #     #   summary.actionData = @settlementActionData

  #     #   $(modal_body).find('.settlement-step-3 .panel-body').html(@tCreditCardFromCardConfirm({summary: @selectedUserSummary}))
  #     when 'credit_card_from_wallet'
  #       $(modal_body).find(".settlement-step-3 .panel-heading .step-title .title").text("Authorize Payment")
  #       _this.settlementActionData.c_card_from_wallet.amount = $(container).find('input[name=amount]').val()
  #       _this.settlementActionData.c_card_from_wallet.note = $(container).find('textarea.note').val()  

  #       summary.userData = @selectedUserSummary
  #       summary.actionData = @settlementActionData

  #       $(modal_body).find('.settlement-step-3 .panel-body').html(@tCreditCardFromWalletConfirm({summary: summary}))
  #     when 'credit_wallet_from_wallet'
  #       $(modal_body).find(".settlement-step-3 .panel-heading .step-title .title").text("Authorize Payment")
  #       _this.settlementActionData.c_wallet_from_wallet.amount = $(container).find('input[name=amount]').val()
  #       _this.settlementActionData.c_wallet_from_wallet.note = $(container).find('textarea.note').val()

  #       summary.userData = @selectedUserSummary
  #       summary.actionData = @settlementActionData
  #       console.log "Summary Action Data is ", summary.actionData, "& userData is", summary.userData
  #       $(modal_body).find('.settlement-step-3 .panel-body').html(@tCreditWalletFromWalletConfirm({summary: summary}))
  #     when 'credit_card_from_virtual_account'
  #       $(modal_body).find(".settlement-step-3 .panel-heading .step-title .title").text("Authorize Payment")
  #       _this.settlementActionData.c_card_from_virtual_account.amount = $(container).find('input[name=amount]').val()
  #       _this.settlementActionData.c_card_from_virtual_account.note = $(container).find('textarea.note').val()

  #       summary.userData = @selectedUserSummary
  #       summary.actionData = @settlementActionData
  #       $(modal_body).find('.settlement-step-3 .panel-body').html(@tCreditCardFromVirtualAccountConfirm({summary: summary}))
  #     when 'credit_wallet_from_virtual_account'
  #       $(modal_body).find(".settlement-step-3 .panel-heading .step-title .title").text("Authorize Payment")
  #       _this.settlementActionData.c_wallet_from_virtual_account.amount = $(container).find('input[name=amount]').val()
  #       _this.settlementActionData.c_wallet_from_virtual_account.note = $(container).find('textarea.note').val()

  #       summary.userData = @selectedUserSummary
  #       summary.actionData = @settlementActionData
  #       $(modal_body).find('.settlement-step-3 .panel-body').html(@tCreditWalletFromVirtualAccountConfirm({summary: summary}))
  #     when 'debit_cash_advance'
  #       $(modal_body).find(".settlement-step-3 .panel-heading .step-title .title").text("Authorize Payment")
  #       _this.settlementActionData.d_cash_advance.amount = $(container).find('input[name=payment\\[amount\\]]').val()
  #       _this.settlementActionData.d_cash_advance.date = $(container).find('input[name=payment\\[date\\]]').val()
  #       _this.settlementActionData.d_cash_advance.note = $(container).find('textarea[name=payment\\[note\\]]').val()

  #       summary.userData = @selectedUserSummary
  #       summary.actionData = @settlementActionData
  #       $(modal_body).find('.settlement-step-3 .panel-body').html(@tDebitCashAdvanceConfirm({summary: summary}))

  #     ## Disabled Feature
  #     # when 'debit_card_to_card' 
  #     #   $(modal_body).find(".settlement-step-3 .panel-heading .step-title .title").text("Authorize Payment")
  #     #   _this.settlementActionData.d_card_to_card.amount = $(container).find('input[name=amount]').val()

  #     #   summary.userData = @selectedUserSummary
  #     #   summary.actionData = @settlementActionData
  #     #   $(modal_body).find('.settlement-step-3 .panel-body').html(@tDebitCardToCardConfirm({summary: summary}))

  #     ## Disabled Feature
  #     # when 'debit_card_to_wallet'
  #     #   $(modal_body).find(".settlement-step-3 .panel-heading .step-title .title").text("Authorize Payment")
  #     #   _this.settlementActionData.d_card_to_wallet.amount = $(container).find('input[name=amount]').val()

  #     #   summary.userData = @selectedUserSummary
  #     #   summary.actionData = @settlementActionData
  #     #   $(modal_body).find('.settlement-step-3 .panel-body').html(@tDebitCardToWalletConfirm({summary: summary}))

  #     when 'debit_wallet_to_wallet'
  #       $(modal_body).find(".settlement-step-3 .panel-heading .step-title .title").text("Authorize Payment")
  #       _this.settlementActionData.d_wallet_to_wallet.amount = $(container).find('input[name=amount]').val()
  #       _this.settlementActionData.d_wallet_to_wallet.note = $(container).find('textarea.note').val()

  #       summary.userData = @selectedUserSummary
  #       summary.actionData = @settlementActionData
  #       $(modal_body).find('.settlement-step-3 .panel-body').html(@tDebitWalletToWalletConfirm({summary: summary}))

  #     when 'debit_wallet_to_virtual_account'
  #       $(modal_body).find(".settlement-step-3 .panel-heading .step-title .title").text("Authorize Payment")
  #       _this.settlementActionData.d_wallet_to_virtual_account.amount = $(container).find('input[name=amount]').val()
  #       _this.settlementActionData.d_wallet_to_virtual_account.note = $(container).find('textarea.note').val()

  #       summary.userData = @selectedUserSummary
  #       summary.actionData = @settlementActionData
  #       $(modal_body).find('.settlement-step-3 .panel-body').html(@tDebitWalletToVirtualAccountConfirm({summary: summary}))
  #   # console.log _this.settlementActionData
  #   $(modal_body).find(".datepicker").datepicker({dateFormat: "dd-mm-yy"})

  # submitAction: (e) ->
  #   e.preventDefault()
  #   _this = @
  #   target = e.currentTarget
  #   $(target).attr("disabled", true)

  #   action_type = $(target).attr('data-action-type')
  #   modal_body = $(target).closest('.modal-body')
  #   $(modal_body).find('#collapse-step-2').collapse('hide')
  #   $(modal_body).find('#collapse-step-3').collapse('show')

  #   container = $(target).closest('#collapse-step-3')

  #   url = $(target).attr('data-url')
  #   data = {}
  #   data.view = _this.params.view
  #   data.authenticity_token = $("#authenticity_token").val()
  #   # console.log action_type

  #   switch action_type
  #     when 'credit_reimbursement'
  #       # console.log "Selected data",_this.settlementActionData
  #       # data.report_ids = _this.settlementActionData.selected.slice()
  #       data.report_ids = _this.settlementActionData.selected.slice()
  #       data.payment = {
  #         note: $(container).find('textarea[name=payment\\[note\\]]').val()
  #         date: $(container).find('input[name=payment\\[date\\]]').val()
  #         amount: parseFloat(_this.selectedReportsTotal())

  #       }
  #       data.password = $(container).find('input[type=password][name=password]').val()
  #       # console.log data
  #     when 'credit_cash_advance'
  #       data.payment = {
  #         amount: _this.settlementActionData.c_cash_advance.amount
  #         date: _this.settlementActionData.c_cash_advance.date
  #         note: _this.settlementActionData.c_cash_advance.note

  #         # payment_type: parseInt($(target).find("input[name=payment\\[payment_type\\]]:checked").val())
  #       }
  #       data.password = $(container).find('input[type=password][name=password]').val()
  #       # data.payment_type = parseInt($(target).find("input[name=payment_type]").val())
  #       # data.payment_type = 1 #Already there in the url
  #       data.password = $(container).find('input[name=password]').val()

  #     when 'credit_money_request'
  #       data.money_request_ids = _this.settlementActionData.selected.slice()
  #       data.payment = {
  #         note: $(container).find('textarea[name=payment\\[note\\]]').val()
  #         date: $(container).find('input[name=payment\\[date\\]]').val()
  #         amount: parseFloat(_this.selectedReportsTotal())
  #       }
  #       data.password = $(container).find('input[type=password][name=password]').val()
  #       # console.log "Submit action data", data
  #     when 'credit_card_from_card'
  #       # data.action_type = x
  #       data.amount = _this.settlementActionData.c_card_from_card.amount
  #       data.password = $(container).find('input[type=password][name=password]').val()
  #       data.to_user_id = _this.user_id
  #       data.note = _this.settlementActionData.c_card_from_card.note

  #     when 'credit_card_from_wallet'
  #       data.amount = _this.settlementActionData.c_card_from_wallet.amount
  #       data.password = $(container).find('input[type=password][name=password]').val()
  #       data.to_user_id = _this.user_id
  #       data.note = _this.settlementActionData.c_card_from_wallet.note

  #     when 'credit_wallet_from_wallet'
  #       data.amount = _this.settlementActionData.c_wallet_from_wallet.amount
  #       data.password = $(container).find('input[type=password][name=password]').val()
  #       data.to_user_id = _this.user_id
  #       data.note = _this.settlementActionData.c_wallet_from_wallet.note

  #     when 'credit_card_from_virtual_account'
  #       data.amount = _this.settlementActionData.c_card_from_virtual_account.amount
  #       data.password = $(container).find('input[type=password][name=password]').val()
  #       data.to_user_id = _this.user_id
  #       data.note = _this.settlementActionData.c_card_from_virtual_account.note

  #     when 'credit_wallet_from_virtual_account'
  #       data.amount = _this.settlementActionData.c_wallet_from_virtual_account.amount
  #       data.password = $(container).find('input[type=password][name=password]').val()
  #       data.to_user_id = _this.user_id
  #       data.note = _this.settlementActionData.c_wallet_from_virtual_account.note

  #     when 'debit_cash_advance'
  #       data.payment = {
  #         amount: _this.settlementActionData.d_cash_advance.amount
  #         date: _this.settlementActionData.d_cash_advance.date
  #         note: _this.settlementActionData.d_cash_advance.note

  #         # payment_type: parseInt($(target).find("input[name=payment\\[payment_type\\]]:checked").val())
  #       }
  #       # data.payment_type = parseInt($(target).find("input[name=payment_type]").val())
  #       # data.payment_type = 1 #Already there in the url
  #       data.password = $(container).find('input[name=password]').val()

  #     when 'debit_wallet_to_wallet'
  #       data.amount = _this.settlementActionData.d_wallet_to_wallet.amount
  #       data.password = $(container).find('input[type=password][name=password]').val()
  #       data.from_user_id = _this.user_id 
  #       data.note = _this.settlementActionData.d_wallet_to_wallet.note

  #     # when 'debit_card_to_company_credits'
  #     #   data.amount = _this.settlementActionData.d_card_to_company_credits.amount
  #     #   data.password = $(container).find('input[type=password][name=password]').val()
  #     #   data.from_user_id = _this.user_id
  #     when 'debit_wallet_to_virtual_account'
  #       data.amount = _this.settlementActionData.d_wallet_to_virtual_account.amount
  #       data.password = $(container).find('input[type=password][name=password]').val()
  #       data.from_user_id = _this.user_id
  #       data.note = _this.settlementActionData.d_wallet_to_virtual_account.note
  #       # console.log data

  #   # console.log data
  #   summary = $(@el).find(".summary")
  #   $.ajax({
  #     url: url,
  #     data: data,
  #     type: "POST",
  #     dataType: 'json',
  #     success: (res) ->
  #       FinlyF.snapNotify(res.messages)
  #       if res.success == true
  #         FinlyF.startMainLoader(summary)
  #         console.log "Shouldn't get inside."
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
  #       else
  #         $(target).attr('disabled', false)
  #     error: (err) ->
  #       console.log "err", err
  #       $(target).attr('disabled', false)
  #   })

  cancelConfirmation: (e) ->
    e.preventDefault()
    target = e.currentTarget
    container = $(e.currentTarget).closest('.modal-body')
    $(container).find('.confirmation-screen').css("display", "none")
    $(container).find('.process-screen').css('display', 'block')

  selectedReportsTotal: ->
    total = _.reduce(@settlementActionData.selectedReports, ((memo, value) ->
      memo + parseFloat((value.get('reimbursement_amount') || value.get('total_amount')))
    ), 0)
    return total

  toggleLoadMoreUsers: (collection) ->
    # console.log "Loading", collection.models.length
    if collection.models.length < 30
      # console.log "Should hide"
      $(@el).find('.load-more-users').css('display', 'none')
    else
      $(@el).find('.load-more-users').css('display', 'inline')

  filter: (e) ->
    e.preventDefault()
    target = e.currentTarget

    container = $(target).closest('.dropdown-filters')

    params = {
      'filter_state': $(container).find(".filter-state").val() || ""
      'filter_role': $(container).find(".filter-role").val() || ""
    }

    if @params.view
      params.view = @params.view


    FinlyF.primary_router.navigate('settlements/params=' + JSON.stringify(params), {trigger: true})

  showBalancePartial: (e) ->
    target = e.currentTarget
    _this = @

    modal = $(target).closest('.modal-body')

    transfer_flow = $(target).attr('data-transfer-flow')
    data = {
      view: _this.params.view
          }

    meta = {
      current_action: {
        action: $(target).attr('data-action')
        url: $(target).attr('data-url')
      }
    }

    switch transfer_flow
      when 'load-finlymoney-card'
        data.target_user_card = true
        data.current_user_wallet = true
        meta.from = 'current_user_wallet'
        meta.to = 'target_user_card'
      when 'load-companybalance-card'
        data.target_user_card = true
        data.virtual_account = true
        meta.from = 'virtual_account'
        meta.to = 'target_user_card'
      when 'load-card-card'
        data.target_user_card = true
        data.current_user_card = true
        meta.from = 'current_user_card'
        meta.to = 'target_user_card'
      when 'withdraw-card-finlymoney'
        data.target_user_card = true
        data.current_user_wallet = true
        meta.from = 'target_user_card'
        meta.to = 'current_user_wallet'
      when 'withdraw-card-card'
        data.target_user_card = true
        data.current_user_card = true
        meta.from = 'target_user_card'
        meta.to = 'current_user_card'
      when 'withdraw-card-companybalance'
        data.target_user_card = true
        data.virtual_account = true
        meta.from = 'target_user_card'
        meta.to = 'virtual_account'
      when 'load-finlymoney-finlymoney'
        data.target_user_wallet = true
        data.current_user_wallet = true
        meta.from = 'current_user_wallet'
        meta.to = 'target_user_wallet'
      when 'load-card-finlymoney'
        data.target_user_wallet = true
        data.current_user_card = true
        meta.from = 'current_user_card'
        meta.to = 'target_user_wallet'
      when 'load-companybalance-finlymoney'
        data.target_user_wallet = true
        data.virtual_account = true
        meta.from = 'virtual_account'
        meta.to = 'target_user_wallet'
      when 'withdraw-finlymoney-finlymoney'
        data.target_user_wallet = true
        data.current_user_wallet = true
        meta.from = 'target_user_wallet'
        meta.to = 'current_user_wallet'
      when 'withdraw-finlymoney-card'
        data.target_user_wallet = true
        data.current_user_card = true
        meta.from = 'target_user_wallet'
        meta.to = 'current_user_card'
      when 'withdraw-finlymoney-companybalance'
        data.target_user_wallet = true
        data.virtual_account = true
        meta.from = 'target_user_wallet'
        meta.to = 'virtual_account'
        # ...
      
    $.ajax({
      url: 'users/' + _this.user_id + '/balance'
      data: data
      type: 'get',
      dataType: 'json'
      success: (res) ->
        item = res
        item.meta = meta
        item.selectedUserSummary = _this.selectedUserSummary 
        console.log "Item", item

        $(modal).find('.settlement-transfer-flow').html(_this.templateTransferFlow({item: item}))
        # console.log res
    }) 


  calculateReimbursement: (e) ->
    console.log "Workign bitch!"
    target = e.currentTarget

    container = $(target).closest('.panel-body')

    total_reimbursement = parseFloat($(container).find('input[name=total_reimbursement]').val() || 0)
    from_cash_in_hand = $(container).find('input[name=from_cash_in_hand]')
    from_outside_finly = $(container).find('input[name=from_outside_finly]')

    if $(target).hasClass('cash-in-hand')
      result = total_reimbursement - parseFloat($(from_cash_in_hand).val() || 0)
      final_result = if result < 0 then 0 else result
      $(from_outside_finly).val(final_result)
    else if $(target).hasClass('outside-finly')
      result = total_reimbursement - parseFloat($(from_outside_finly).val() || 0)
      final_result = if result < 0 then 0 else result
      $(from_cash_in_hand).val(final_result)















