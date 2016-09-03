class FinlyF.Views.UsersIndex extends Backbone.View
  templateSkeleton: HandlebarsTemplates['finlyf/users/skeleton']

  initialize: (options) ->
    @collection = new FinlyF.Collections.Users()
    @collection.fetch({
      reset: true
    })
    @collection.on('reset', @processUsers, @)
    

  render: ->
    
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
      url: '/settlements/summary?id=' + id.toString(),
      dataType: 'json',
      data: {
        authenticity_token: $("#authenticity_token").val()
      },
      success: (res) ->
        # console.log "res", res
        $(_this.el).find(".summary").html(_this.templateSummary({item: res}))
      error: (err) ->
        console.log err

    })

  processUsers: ->
    console.log "processing users"
    @dump = @collectoinUsers.models.slice()
    $(@el).find("#users").html("")

    @collectoinUsers.each(@appendUsers, @)

  appendUsers: (user) ->
    console.log "appending users"
    view_user = new FinlyF.Views.User({model: user, settlements: true})
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
    # $(target).closest('ul').find('a').removeClass('active')
    # $(target).parent().addClass('active')
    # console.log $(target).parent().html()
    view_to_load = $(target).attr('data-view')

    params = {
      # 'filter_status': status_id
      'view_to_load': view_to_load
    }
    if @view == 'personal'
      FinlyF.primary_router.navigate(@collection.url + '/params=' + JSON.stringify(params), {trigger: true})
    else
      console.log @collection.url
      @collection.fetch({
        data: {
          view_to_load: view_to_load
        },
        reset: true,
        # data: _this.params
        success: ->
          _this.populateSummary(user_id)

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
    e.preventDefault()
    FinlyF.navigate(e, @params)


  changeView: (e) ->
    e.preventDefault()
    FinlyF.changeView(e)

  userSettlements: (e) ->
    target = e.currentTarget
    $(target).siblings().removeClass("active")
    $(target).addClass("active")
    _this = @
    user_id = $(target).find(".user-name").attr("data-item-id")
    console.log "User id is", user_id
    console.log @collection.url
    @collection.url = "/settlements/" + user_id.toString()
    @collection.fetch({
      reset: true,
      data: _this.params
      success: ->
        _this.populateSummary(user_id)

      error: ->
        console.log "Couldn't fetch Successfully."
    })




