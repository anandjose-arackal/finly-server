class FinlyF.Views.UsersIndex extends Backbone.View
  templateSkeleton: HandlebarsTemplates['finlyf/users/skeleton']

  #navbar
  templateNavbarSidebar: HandlebarsTemplates['finlyf/users/navbar/navbar_sidebar']
  templateNavbarMain: HandlebarsTemplates['finlyf/users/navbar/navbar_main']

  events:
    'click .user': 'showDetails'

  initialize: (options) ->
    @params = options.params
    @collection = new FinlyF.Collections.Users()
    @collection.fetch({
      reset: true
    })
    @collection.on('reset', @processUsers, @)
    

  render: ->
    $(@el).html(@templateSkeleton())
    $(@el).find(".secondary-navbar .navbar-sidebar").html(@templateNavbarSidebar())
    $(@el).find(".secondary-navbar .navbar-main").html(@templateNavbarMain())
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


  processUsers: ->
    console.log "processing users"
    @dump = @collection.models.slice()
    $(@el).find("#users").html("")

    @collection.each(@appendUsers, @)

  appendUsers: (user) ->
    console.log "appending users"
    view_user = new FinlyF.Views.User({model: user, page: 'users'})
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


  showDetails: (e) ->
    console.log "shwoing details"
    model_id = $(e.currentTarget).attr('data-item-id')
    model = @collection.get(model_id)

    preview_view = new FinlyF.Views.User({
      model: model,
      page: 'user'
      # preview: true
      # parent: @
    })

    $(@el).find("#user-details").html(preview_view.render().el)

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




