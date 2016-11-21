class FinlyF.Views.Policy extends Backbone.View
  #sidebar
  templateSidebar: HandlebarsTemplates['finlyf/policies/sidebar/sidebar']
  #main
  templateSkeleton: HandlebarsTemplates['finlyf/policies/base/skeleton']

  events:
    'click .navigate-tab li a': 'navigateTab'
    'click .btn-new-rule': 'newRule'

    'submit form#form-create-rule': 'createRule'
    'hidden.bs.modal #modal-create-rule': 'clearDiv'
    'submit form.form-remove-rule': 'removeRule'

    # Policies
    'click #btn-assign-users-to-policy': 'initAssignUserstoPolicy'
    'hidden.bs.modal #modal-assign-user-policy': 'clearDiv'
    'change input.select-invitable-user': 'selectUserstoAssign'

    'click #addUsersToPolicyButton': 'assignUserstoPolicy'


    # for unassigning from policy
    'change input.select-assigned-user': 'selectUserstoUnAssign'
    'click #btn-unassign-users-to-policy': 'unAssignUsersfromPolicy'

    #policy member settings
    'click .policy-member-settings': 'initPolicyMemberSettings'

  initialize: (options) ->
    @policy_id = options.id
    console.log options
    if options
      @params = options.params || {}
    else
      @params = {}
    @params.view = @params.view || 'admin'
    unless @params.tab
      @params.tab = @params.tab || 'expense_rules'
      # FinlyF.primary_router.navigate('settings/params=' + JSON.stringify(@params), {trigger: false})


  render: ->
    $(@el).html(@templateSkeleton())
    $(@el).find(".sidebar").html(@templateSidebar({item: @params}))
    @policyName()
    @fetchTabContent()
    FinlyF.structureActions(@el, @params)
    @

  navigateTab: (e) ->
    e.preventDefault();
    a = e.currentTarget
    li = $(a).parent()
    lis = $(a).parent().siblings('li')

    $(lis).removeClass("active")
    $(li).addClass('active')
    tab_name = $(li).attr('data-tab-navigate')
    @params.tab = tab_name
    @fetchTabContent()

    # FinlyF.primary_router.navigate('settings/params=' + JSON.stringify(@params), {trigger: false})

  policyName: ->
    # Fetch Policy Name
    _this = @

    $.ajax({
      url: '/policies/details'
      dataType: 'json',
      data: {
        id: @policy_id
      }
      success: (res) ->
        $(_this.el).find('#policy-name').html(res.name)
      error: (err) ->
        console.log "Err", err

    })

  fetchTabContent: ->
    # Continue with fetching content
    main = $(@el).find(".main")
    current_tab = $(@el).find('.main #' + @params.tab)

    $(current_tab).removeClass('hidden').siblings(".row").addClass('hidden')
    FinlyF.startMainLoader(main)

    url = $(current_tab).attr('data-url')
    # console.log "inside"
    # if $(tab).find(".content-fetched")
    # console.log "hello"
    $.ajax({
      url: url,
      dataType: 'html',
      data: {
        id: @policy_id
        view: @params.view
      }
      success: (res) ->
        # console.log res
        FinlyF.stopMainLoader()
        $(current_tab).html(res)
      error: (err) ->
        console.log "Error", err
    })

  newRule: (e) ->
    e.preventDefault()
    target = e.currentTarget

    rule_type = $(target).attr('data-rule-type')
    rule_category = $(target).attr('data-rule-category')
    modal = $(@el).find('#modal-create-rule')

    $(modal).modal('show')

    $.ajax({
      url: '/policies/create_rule',
      data: {
        id: @policy_id,
        view: @params.view
        rule_type: rule_type
        rule_category: rule_category
      },
      dataType: 'html',
      success: (res) ->
        $(modal).html(res)
      error: (err) ->
        $(modal).modal('hide')
        alert("Oops! Something went wrong. Please try again.")
    })

  createRule: (e) ->
    e.preventDefault()
    _this = @
    form = e.currentTarget
    button = $(form).find('.btn-create-rule')

    $(button).attr('disabled', true)

    modal = $(@el).find('#modal-create-rule')

    url = $(form).attr('action')

    $.ajax({
      url: url,
      data: $(form).serialize(),
      type: "POST",
      dataType: 'json',
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          $(modal).modal('hide')
          _this.fetchTabContent()
        else
          $(button).attr('disabled', false)
          # ohSnap("Successfully requested for a demo. Thank you.", {color: 'green', 'duration': '6000'});
      error: (err) ->
        $(button).attr('disabled', false)

    })

  removeRule: (e) ->
    e.preventDefault()
    _this = @

    form = e.currentTarget

    modal = $(@el).find('#modal-create-rule')

    url = $(form).attr('action')

    $.ajax({
      url: url,
      data: $(form).serialize(),
      type: "DELETE",
      dataType: 'json',
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          _this.fetchTabContent()
          # ohSnap("Successfully requested for a demo. Thank you.", {color: 'green', 'duration': '6000'});
    })


  initAssignUserstoPolicy: (e) ->
    e.preventDefault()
    modal = $(@el).find("#modal-assign-user-policy")

    $(modal).modal('show')

    $.ajax({
      url: '/policies/' + @policy_id + '/invitable_users'
      dataType: 'html',
      type: "POST"
      data: {
        view: @params.view,
        policy_id: @policy_id
      },
      success: (res) ->
        $(modal).html(res)
      error: (err) ->
        $(modal).modal('hide')
        alert("Oops! Something went wrong. Please try again.")
    })

  selectUserstoAssign: (e) ->
    button = $(@el).find("#addUsersToPolicyButton")
    flag = false
    @selected_invitable_users = []

    invitable_users = $(@el).find("#invitable-users .invitable-user")
    for user in invitable_users
      if $(user).find("input.select-invitable-user").prop('checked')
        user_id = $(user).attr('data-user-id')
        @selected_invitable_users.push(user_id)
        flag = true

    console.log "Selected Users", @selected_invitable_users
    if flag == true
      $(button).removeClass('hidden')
    else
      $(button).addClass('hidden')

  

  assignUserstoPolicy: (e) ->
    e.preventDefault()
    _this = @
    target = e.currentTarget
    $(target).attr('disabled', true)

    modal = $(@el).find("#modal-assign-user-policy")

    url = $(target).attr('data-url')

    $.ajax({
      url: url,
      type: 'post',
      dataType: 'json',
      data: {
        user_id: _this.selected_invitable_users.join(",")
        authentication_token: $("#authentication_token").val()
        view: _this.params.view
      },
      success: (res) ->
        console.log "Res", res
        if res.success == true
          FinlyF.snapNotify(res.messages)
          $(modal).modal('hide')
          _this.fetchTabContent()
        else 
          $(target).attr('disabled', false)
      error: (err) ->
        $(target).attr('disabled', false)
        console.log "err", err

    })

  selectUserstoUnAssign: (e) ->
    button = $(@el).find("#btn-unassign-users-to-policy")
    flag = false
    @selected_assigned_users = []

    assigned_users = $(@el).find("#assigned-users .assigned-user")
    for user in assigned_users
      if $(user).find("input.select-assigned-user").prop('checked')
        user_id = $(user).attr('data-user-id')
        @selected_assigned_users.push(user_id)
        flag = true

    console.log "Selected Users", @selected_assigned_users
    if flag == true
      $(button).removeClass('hidden')
    else
      $(button).addClass('hidden')

  unAssignUsersfromPolicy: (e) ->
    e.preventDefault()
    _this = @
    target = e.currentTarget
    $(target).attr('disabled', true)

    url = $(target).attr('data-url')

    $.ajax({
      url: url,
      type: 'post',
      dataType: 'json',
      data: {
        user_id: _this.selected_assigned_users.join(",")
        authentication_token: $("#authentication_token").val()
        view: _this.params.view
      },
      success: (res) ->
        # console.log "Res", res
        if res.success == true
          FinlyF.snapNotify(res.messages)
          # $(modal).modoal('hide')
          _this.fetchTabContent()
        else 
          $(target).attr('disabled', false)
      error: (err) ->
        $(target).attr('disabled', false)
        console.log "err", err

    })


  initPolicyMemberSettings: (e) ->
    e.preventDefault()
    target = e.currentTarget
    user_id = $(target).attr('data-user-id')
    modal = $(@el).find("#modal-policy-member-settings")

    $(modal).modal('show')

    $.ajax({
      url: '/policies/policy_member_settings'
      dataType: 'html',
      data: {
        view: @params.view,
        policy_id: @policy_id
        user_id: user_id
      },
      success: (res) ->
        $(modal).html(res)
      error: (err) ->
        $(modal).modal('hide')
        alert("Oops! Something went wrong. Please try again.")
    })


  clearDiv: (e) ->
    target = e.currentTarget
    $(target).html("")