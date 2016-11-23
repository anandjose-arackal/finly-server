class FinlyF.Views.Statement extends Backbone.View
  templateSkeleton: HandlebarsTemplates['finlyf/statements/base/skeleton']
  templateSidebar: HandlebarsTemplates['finlyf/statements/sidebar/sidebar']
  templateNavbarMainSummary: HandlebarsTemplates['finlyf/statements/navbar/navbar_main']
  templateNavbarMainTransactions: HandlebarsTemplates['finlyf/statements/navbar/navbar_main']

  templateMain: HandlebarsTemplates['finlyf/statements/crud/main']

  events:
    'click .filter-statements': 'filterStatements'

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


    # $.ajax({
    #   url: '/statements/' + @user + '/summary'
    #   dataType: 'json'
    #   data: @params

    #   success: (res) ->
    #     _this.populateSummary(res)
    #   error: (err) ->
    #     console.log "Err", err
    # })


  render: ->
    $(@el).html(@templateSkeleton({item: @params}))
    $(@el).find(".sidebar").html(@templateSidebar())
    $(@el).find(".navbar-main").html(@templateNavbarMain({item: @params}))

    FinlyF.structureActions(@el, @params)
    @

  fetchTabDate: ->
    switch @params.statement_type
      when 'summary'
        url = '/statements/' + @user + '/summary'
      when 'transactions'
        url = '/statements/' + @user
      else
        @params.statement_type = 'summary'
        url = '/statements/' + @user + '/summary'


    $.ajax({
      url: url
      dataType: 'json'
      data: @params
      success: (res) ->
        _this.populateSummary(res)
      error: (err) ->
        console.log "Err", err
    })
    

  populateSummary: (item) ->
    if @params.statement_type == 'summary'
      $(@el).find(".main").html(@templateMainSummary({item: item}))
    else
      $(@el).find(".main").html(@templateMainTransactions({item: item}))


  filterStatements: (e) ->
    e.preventDefault()
    target = e.currentTarget

    @params.filter_state = parseInt($(target).attr('data-filter-state'))

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

