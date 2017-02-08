class FinlyF.Views.CompanyStatements extends Backbone.View
  templateSkeleton: HandlebarsTemplates['finlyf/statements/base/skeleton']
  templateSidebar: HandlebarsTemplates['finlyf/statements/company/sidebar/sidebar']

  templateNavbarMain: HandlebarsTemplates['finlyf/statements/company/navbar/navbar_main']
  templateNavbarSidebar: HandlebarsTemplates['finlyf/statements/company/navbar/navbar_sidebar']

  templatePoliciesSummary: HandlebarsTemplates['finlyf/statements/company/crud/policiesSummary']
  templateCompanyTransactionSummary: HandlebarsTemplates['finlyf/statements/company/crud/companyTransactionSummary']
  templateCompanyBalanceSummary: HandlebarsTemplates['finlyf/statements/company/crud/companyBalanceSummary']
  # templateMainTransactions: HandlebarsTemplates['finlyf/statements/crud/mainTransactions']

  events:
    'click li.filter-statement-type': 'filterStatementType'
    'change input.filter-date-from, input.filter-date-to': 'fetchScopedData'
    'click .btn-export-transactions': 'exportTransactions'
    'click .navigate-tab li a': 'navigateTab'

  initialize: (options) ->
    # console.log "Init, ", options
    _this = @
    if options
      if options.params
        @params = options.params
      else
        @params = {}
    else
      @params = {}

    @params.statement_type = @params.statement_type || 'company_policies_summary'
    today = new Date()
    @params.filter_date_from = @formatDate(new Date(today.getTime() - 30*24*60*60*1000))
    @params.filter_date_to = @formatDate(today)


    # $.ajax({
    #   url: '/users/' + @user
    #   dataType: 'json'
    #   data: {
    #     view: _this.params.view
    #   }
    #   success: (res) ->
    #     _this.populateUserData(res)
    #   error: (err) ->
    #     console.log "Err", err
    # })


  render: ->
    console.log "In render"
    $(@el).html(@templateSkeleton({item: @params}))
    $(@el).find(".sidebar").html(@templateSidebar())
    $(@e).find(".navbar-sidebar").html(@templateNavbarSidebar())

    FinlyF.structureActions(@el, @params)
    @fetchTabData()
    @

  fetchScopedData: (e) ->
    target = e.currentTarget
    if $(target).hasClass('filter-date-from')
      @params.filter_date_from = $(target).val()
    else
      @params.filter_date_to = $(target).val()
    FinlyF.startMainLoader($(@el).find('.main'))
    @fetchTabData()

  fetchTabData: ->
    current_tab = $(@el).find('.sidebar .statements-type li[data-tab-navigate="' + @params.statement_type + '"]')

    $(current_tab).addClass('active').siblings("li").removeClass('active')
    main = $(@el).find('.main')
    # FinlyF.startMainLoader(main)



    # Will change this one..
    $(@el).find(".navbar-main").html(@templateNavbarMain({item: @params}))
    $(@el).find(".datepicker").datepicker({dateFormat: "dd-mm-yy"})
    _this = @
    switch @params.statement_type
      when 'company_balance_summary'
        url = '/statements/' + 'company_balance_summary'
      when 'company_transactions_summary'
        url = '/statements/' + 'company_transactions_summary'
      when 'company_policies_summary'
        url = '/statements/' + 'company_policies_summary'
      else
        @params.statement_type = 'company_balance_summary'
        url = '/statements/' + 'company_balance_summary'

    $.ajax({
      url: url
      dataType: 'json'
      data: @params
      success: (res) ->
        FinlyF.stopMainLoader($(_this.el).find('.main'))
        _this.populateSummary(res)
      error: (err) ->
        console.log "Err", err
    })

  navigateTab: (e) ->

    e.preventDefault()
    li = $(e.currentTarget).parent()

    statement_type = $(li).attr('data-tab-navigate')

    @params.statement_type = statement_type
    @fetchTabData()
    

  populateSummary: (item) ->
    switch @params.statement_type
      when 'company_balance_summary'
        $(@el).find(".main").html(@templateCompanyBalanceSummary({item: item}))
      when 'company_transactions_summary'
        $(@el).find(".main").html(@templateCompanyTransactionSummary({item: item}))
      when 'company_policies_summary'
        $(@el).find(".main").html(@templatePoliciesSummary({item: item}))

  populateUserData: (item) ->
    $(@el).find(".sidebar").html(@templateSidebar({item: item}))

  filterStatementType: (e) ->
    FinlyF.startMainLoader($(@el).find('.main'))
    e.preventDefault()
    target = e.currentTarget

    @params.statement_type = $(target).attr('data-show-type')
    console.log @params
    @fetchTabData()

  exportTransactions: (e) ->
    e.preventDefault()
    target = e.currentTarget

    export_type = $(target).attr('data-export-type')
    url = "/export/" + @user + "/statements" + '.' + export_type + "?filter_date_from=" + @params.filter_date_from + "&filter_date_to=" + @params.filter_date_to
    window.open(url,'_blank');

  formatDate: (d) ->
    console.log d
    # d = new Date(date)
    month = d.getMonth() + 1
    day = d.getDate()
    year = d.getFullYear()

    console.log month, day, year
    if month.length < 2
      month = '0' + month
    if day.length < 2
      day = '0' + day
    [
      year
      month
      day
    ].join '-'

