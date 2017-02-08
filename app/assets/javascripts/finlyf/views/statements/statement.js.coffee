class FinlyF.Views.Statement extends Backbone.View
  templateSkeleton: HandlebarsTemplates['finlyf/statements/base/skeleton']
  templateSidebar: HandlebarsTemplates['finlyf/statements/sidebar/sidebar']
  templateNavbarSidebar: HandlebarsTemplates['finlyf/statements/navbar/navbarSidebar']
  templateNavbarMain: HandlebarsTemplates['finlyf/statements/navbar/navbar_main']

  templateMainSummary: HandlebarsTemplates['finlyf/statements/crud/mainSummary']
  templateMainTransactions: HandlebarsTemplates['finlyf/statements/crud/mainTransactions']

  events:
    'click li.filter-statement-type': 'filterStatementType'
    'change input.filter-date-from, input.filter-date-to': 'fetchScopedData'
    'click .btn-export-transactions': 'exportTransactions'

  initialize: (options) ->
    _this = @
    if options
      @user = options.user
      if options.params
        @params = options.params
      else
        @params = {}

    @params.statement_type = 'summary'
    today = new Date()
    @params.filter_date_from = @formatDate(new Date(today.getTime() - 30*24*60*60*1000))
    @params.filter_date_to = @formatDate(today)


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


  render: ->
    $(@el).html(@templateSkeleton({item: @params}))
    $(@el).find(".navbar-sidebar").html(@templateNavbarSidebar())
    $(@el).find(".sidebar").html(@templateSidebar())

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
    $(@el).find(".navbar-main").html(@templateNavbarMain({item: @params}))
    $(@el).find(".navbar-sidebar").html(@templateNavbarSidebar({item: @params}))

    $(@el).find(".datepicker").datepicker({dateFormat: "dd-mm-yy"})
    _this = @
    switch @params.statement_type
      when 'summary'
        url = '/statements/' + @user + '/summary'
      when 'transactions'
        url = '/statements/' + @user
        # url = '/statements/' + @user + '/summary'
      else
        @params.statement_type = 'summary'
        url = '/statements/' + @user + '/summary'


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
    

  populateSummary: (item) ->
    if @params.statement_type == 'summary'
      $(@el).find(".main").html(@templateMainSummary({item: item}))
    else
      $(@el).find(".main").html(@templateMainTransactions({item: item}))

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

