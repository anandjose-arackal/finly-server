class FinlyF.Views.UsersIndex extends Backbone.View
  templateSkeleton: HandlebarsTemplates['finlyf/users/skeleton']

  #navbar
  templateNavbarSidebar: HandlebarsTemplates['finlyf/users/navbar/navbar_sidebar']
  templateNavbarMain: HandlebarsTemplates['finlyf/users/navbar/navbar_main']

  #Employees
  templateInviteEmployee: HandlebarsTemplates['finlyf/users/inviteEmployee']

  events:
    #Filter by state
    'click .filter-state': 'filterState'
    'click .navbar-view-type': 'changeView'

    'click .load-more-users': 'loadMoreUsers'


    'click .navbar-menu-li': 'navigate'
    'click .user': 'showDetails'

    'change select[name=invite_by]': 'changeInviteBy'
    'click .btn-invite-employee': 'processEmployeeInvitation'
    'click .btn-confirm-invite-employee': 'inviteEmployee'

    'click .btn-import-employees': 'processImport'
    'submit #form-import-employees': 'importEmployees'
    # 'ajax:success #form-import-employees': 'importEmployees'

    'change #modal-mp .conditional-container input[type=radio]': 'showOptionalManagers'

    'keyup .search-user': 'prepareSearch'
    'submit .navbar-form': 'cancelEvents'

    # Temp Dropdown Filters
    'click .btn-filter': 'filter'

  initialize: (options) ->
    _this = @
    @params = options.params
    unless @params.filter_state
      @params.filter_state = 1
    @collection = new FinlyF.Collections.Users()
    @collection.fetch({
      reset: true,
      data: @params
      success: ->
        _this.toggleLoadMoreUsers(_this.collection)
    })
    @dump = []
    @collection.on('reset', @processUsers, @)
    @on('refresh', @refetchCollection, @)

  render: ->
    $(@el).html(@templateSkeleton())
    $(@el).find(".secondary-navbar .navbar-sidebar").html(@templateNavbarSidebar({item: @params}))
    $(@el).find(".secondary-navbar .navbar-main").html(@templateNavbarMain())
    FinlyF.structureActions(@el, @params) 
    @

  # loadMore: (e) ->
  #   _this = @
  #   target = $(e.currentTarget)
  #   $(target).find('i').removeClass('fa-cloud-download').addClass('fa-spinner fa-pulse')
  #   $(target).find('span').text('Loading....')
  #   @params.page = (parseInt($(target).attr("data-page")) || 0 ) + 1

  #   @collection.fetch({
  #     data: _this.params,
  #     reset: false,
  #     success: ->
  #       _this.toggleLoadMoreUsers(_this.collection)
  #       $(target).find('i').addClass('fa-cloud-download').removeClass('fa-spinner fa-pulse')
  #       $(target).find('span').text('Load More')
  #       _this.resetPageCount({target: target, page: _this.params.page })

  #       _this.dump = (_this.dump.concat(_this.collection.models.slice())).slice()
  #       _this.collection.reset(_this.dump)

  #     error: ->
  #       console.log "Couldn't fetch Successfully."
  #   })

  processUsers: ->
    # console.log "processing users"
    @dump = @collection.models.slice()
    $(@el).find("#users").html("")

    # Stop main loader
    main = $(@el).find('.sidebar')
    FinlyF.stopMainLoader(main)

    @collection.each(@appendUsers, @)

  appendUsers: (user) ->
    # console.log "appending users"
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
    
    FinlyF.stopMainLoader()

  showDetails: (e) ->
    $(e.currentTarget).siblings().removeClass('active')
    $(e.currentTarget).addClass('active')
    # console.log "shwoing details"
    model_id = $(e.currentTarget).attr('data-item-id')
    model = @collection.get(model_id)

    preview_view = new FinlyF.Views.User({
      model_id: model.get('id'),
      page: 'user'
      params: @params
      parent: @
      # preview: true
      # parent: @
    })

    $(@el).find("#user-details").html(preview_view.render().el)
    # Load main loader
    main = $(@el).find("#user-details .user-details")
    FinlyF.startMainLoader(main)

  refetchCollection: (e) ->
    #REFRESH
    #Spin refresh-spinner
    _this = @
    if e
      target = e.currentTarget
      $(target).find("i").addClass("fa-spin")

    @params.page = 1
    # console.log @params
    @collection.fetch({
      reset: true,
      data: _this.params,
      success: ->
        _this.dump.length = 0
        _this.dump = _this.collection.models.slice()
        _this.resetPageCount({selector: '.main .load-more', page: 1})

        $(_this.el).find("#user-details").html("<div class='col-sm-10 col-sm-offset-1'><h2>Please Select an Employee from the list on the left to view/edit their details, policies, roles etc.</h2></div>")

      error: ->
        console.log "Couldn't fetch successfully."
    })

  loadMoreUsers: (e) ->
    e.preventDefault()
    _this = @
    target = $(e.currentTarget)
    $(target).find('i').removeClass('fa-cloud-download').addClass('fa-spinner fa-pulse')
    $(target).find('span').text('Loading....')
    @params.page = (parseInt($(target).attr("data-page")) || 0 ) + 1

    @collection.fetch({
      data: _this.params,
      reset: false,
      success: ->
        _this.toggleLoadMoreUsers(_this.collection)
        $(target).find('i').addClass('fa-cloud-download').removeClass('fa-spinner fa-pulse')
        $(target).find('span').text('Load More')
        _this.resetPageCount({target: target, page: _this.params.page })

        _this.dump= (_this.dump.concat(_this.collection.models.slice())).slice()
        _this.collection.reset(_this.dump)

      error: ->
        console.log "Couldn't fetch Successfully."
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
      # console.log @collection.url
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

  changeInviteBy: (e) ->
    target = e.currentTarget

    invite_by_div = $(target).closest('.invite_by')

    invite_by = $(target).val()

    if invite_by == 'mobile'
      $(invite_by_div).find("input.invite-by-type").val('mobile')
      $(invite_by_div).find('input.input-invite-by-email').addClass('hidden').attr('disabled', true)
      $(invite_by_div).find('input.input-invite-by-mobile').removeClass('hidden').attr('disabled', false)
    else if invite_by == 'email'
      $(invite_by_div).find("input.invite-by-type").val('email')
      $(invite_by_div).find('input.input-invite-by-mobile').addClass('hidden').attr('disabled', true)
      $(invite_by_div).find('input.input-invite-by-email').removeClass('hidden').attr('disabled', false)

  processEmployeeInvitation: ->
    _this = @

    modal = $(@el).find("#modal-mp")
    $(modal).modal('show')

    $.ajax({
      url: '/users/get_managers'
      dataType: 'json'
      data: @params
      success: (res) ->
        unless res.company.roles.company_admin == true
          $(modal).modal('hide')
          ohSnap('You do not have appropriate permission to invite!', 'color': 'red', 'duration': 6000, 'container-id': 'ohsnap-priority')
        else
          FinlyF.snapNotify(res.messages)
          $(modal).html(_this.templateInviteEmployee({item: res}))
          $(modal).find('input[name=authenticity_token]').val($("#authenticity_token"))
          if _this.params.view == 'manager'
            $(modal).find('.invitee-managed-by').val(res.company.current_user_id).prop('disabled', 'disabled')
          else if _this.params.view == 'finance_manager'
            $(modal).find('.invitee-finance-managed-by').val(res.company.current_user_id).prop('disabled', 'disabled')
        
      error: (err) ->
        FinlyF.snapNotify(err.messages)
        $(modal).modal('hide')
        console.log "Err", err
    })

  inviteEmployee: (e) ->
    e.preventDefault()
    _this = @
    target = e.currentTarget
    $(target).attr('disabled', true)
    modal = $(e.currentTarget).closest('#modal-mp')
    form = $(e.currentTarget).closest('.modal-content').find('.modal-body form.new-invite-employee')
    values = {}

    manager = $(form).find('input[name=manager]:checked')
    finance_manager  = $(form).find('input[name=finance_manager]:checked')
    if $(manager).val() == 0
      $(manager).closest('.conditional-container').find('.conditional-managers .select-conditional-manager').val("")

    if $(finance_manager).val() == 0
      $(finance_manager).closest('.conditional-container').find('.conditional-managers .select-conditional-manager').val("")

    # console.log manager, finance_manager
    # return

    $(form).find(':disabled').removeAttr('disabled');

    _.each((form).serializeArray(), (input) ->
      values[ input.name ] = input.value
    )
    
    # console.log values
    $.ajax({
      url: "/pending_invites"
      type: "POST",
      dataType: 'json'
      data: values
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          $(modal).modal('hide')
          if parseInt(_this.params.filter_state) == 2
            _this.refetchCollection()
        else
          $(target).attr('disabled', false)

        # console.log res
      error: (err) ->
        console.log "Err", err
        $(target).attr('disabled', false)
    })


  processImport: (e) ->
    e.preventDefault()
    target = e.currentTarget

    modal = $(@el).find("#modal-import-employees")
    $(modal).modal('show')
    $(modal).find("input[name=authenticity_token]").val($("#authenticity_token").val())

  importEmployees: (e) ->
    # console.log "Success", e
    # target = e.currentTarget

    # $(target).find('input[type=submit]').attr('disabled', true).val('Submitted!')
    # e.preventDefault()
    # target = e.currentTarget
    # url = $(target).attr('action')

    # # $(target).html("&nbsp;&nbsp;&nbsp;<i class='fa fa-spin fa-circle-o-notch'></i>&nbsp;&nbsp;&nbsp;").attr('disabled', 'disabled')
    # formData = new FormData(target)

    # $.ajax({
    #   url: url,
    #   type: "POST",
    #   dataType: 'csv',
    #   data: formData,
    #   success: (res) ->
    #     console.log res
    #     # FinlyF.snapNotify(res.messages)
    #     # if res.success == true
    #     #   $("#modal-new").modal('hide')
    #     #   _this.refetchCollection()
    #     # else
    #     #   $(target).html("Create")
    #     #   $(target).attr('disabled', false)
    #   error: (err) ->
    #     console.log "Error", err 
    #     # $(target).attr('disabled', false)
    #   cache: false,
    #   contentType: false,
    #   processData: false
    # })



  filterState: (e) ->
    e.preventDefault()
    target = e.currentTarget
    @params.page = 1

    @params.filter_state = parseInt($(target).attr('data-filter-state'))

    FinlyF.primary_router.navigate('employees/params=' + JSON.stringify(@params), {trigger: true})

  cancelEvents: (e) ->
    e.preventDefault()

  prepareSearch: (e) ->
    # console.log "abinash"
    # console.log _.debounce(@searchUser(e), 500, true)
    if $(e.currentTarget).val().length > 2 || $(e.currentTarget).val().length == 0
      @searchUser(e)

  searchUser: (e) ->
    _this = @
    query = $(e.currentTarget).val()
    @collection.fetch({
      reset: true,
      data: {
        view: @params.view
        filter_state: @params.filter_state
        filter_search: query
      }
      success: ->
        _this.toggleLoadMoreUsers(_this.collection)
    }) 

  ##Funactionalities
  showOptionalManagers: (e) ->
    target = $(e.currentTarget)
    if parseInt($(target).val()) == 1
      $(target).closest('.conditional-container').find('.conditional-managers').slideDown('fast')
    else
      $(target).closest('.conditional-container').find('.conditional-managers').slideUp('fast')
      unless $(target).closest('.conditional-container').find('.conditional-managers .select-conditional-manager').prop('disabled')
        $(target).closest('.conditional-container').find('.conditional-managers .select-conditional-manager').val("")

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

  toggleLoadMoreUsers: (collection) ->
    # console.log "Loading", collection.models.length
    if collection.models.length < 5
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


    FinlyF.primary_router.navigate('employees/params=' + JSON.stringify(params), {trigger: true})