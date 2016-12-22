class FinlyF.Views.Policy extends Backbone.View
  #sidebar
  templateSidebar: HandlebarsTemplates['finlyf/policies/sidebar/sidebar']
  #main
  templateSkeleton: HandlebarsTemplates['finlyf/policies/base/skeleton']

  templateAddCondition: HandlebarsTemplates['finlyf/policies/extras/addCondition']
  
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
    'submit form#form-policy-member-settings': 'updatePolicyMemberSettings'
    'click .btn-add-condition': 'newCondition'
    'click .btn-remove-condition': 'removeCondition'

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

    # console.log "Selected Users", @selected_invitable_users
    if flag == true
      $(button).removeAttr('disabled')
    else
      $(button).attr('disabled', true)

  

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

    # console.log "Selected Users", @selected_assigned_users
    if flag == true
      $(button).removeAttr('disabled')
    else
      $(button).attr('disabled', true)

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
        selects = $(modal).find("select.select-assign-manager")
        for select in selects
          $(select).val($(select).attr('data-default-value'))
      error: (err) ->
        $(modal).modal('hide')
        alert("Oops! Something went wrong. Please try again.")
    })

  updatePolicyMemberSettings: (e) ->
    e.preventDefault()
    _this = @
    form = e.currentTarget
    modal = $(form).closest('.modal')
    button = $(form).find("button.btn-update-policy-member-settings")
    $(button).html("&nbsp;&nbsp;<i class='fa fa-spinner fa-spin'></i>&nbsp;&nbsp;").attr('disabled', true)
    user_id = $(form).find("button.btn-update-policy-member-settings").attr('data-user-id')
    


    $.ajax({
      url: '/users/' + user_id,
      data: $(form).serialize(),
      type: 'PUT',
      processData: true,
      dataType: 'json',
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          $(modal).modal('hide')
          _this.fetchTabContent()
        else
          $(button).html("Update").removeAttr('disabled')
      error: (err) ->
        console.log "Err", err
        $(button).html("Update").removeAttr('disabled')
    })

  newCondition: (e) ->
    _this = @
    e.preventDefault()
    target = $(e.currentTarget)
    policy = $(target).closest('.policy-rules')

    arr = []
    conditionals = $(policy).find('.conditional')
    # console.log "count", conditionals.length
    for conditional in conditionals
      # console.log "Conditional counter", $(conditional).attr('data-condition-serial')
      arr.push(parseInt($(conditional).attr('data-condition-serial')))

    # console.log Math.max.apply(Math,arr) + 1

    modal = $(target).closest('.modal')
    managers = []
    finance_managers = []
    managers_data = $(modal).find("select.data-team-managers option")
    finance_managers_data = $(modal).find("select.data-team-finance-managers option")

    for manager in managers_data
      m = {
        id: $(manager).val()
        name: $(manager).text()
      }
      managers.push(m)

    for finance_manager in finance_managers_data
      m = {
        id: $(finance_manager).val()
        name: $(finance_manager).text()
      }
      finance_managers.push(m)

    item = {
      # condition_serial: Math.max.apply(Math,arr) + 1
      policy_id: $(target).attr('data-policy-id')
      manager_type: $(target).attr('data-manager-type')
      managers: managers
      finance_managers: finance_managers
    }
    if arr.length == 0
      item.condition_serial = 1
    else
      item.condition_serial = Math.max.apply(Math,arr) + 1

    console.log "Item", item

    # console.log item
    $(target).closest('.add-condition').before(@templateAddCondition({item: item}))

  removeCondition: (e) ->
    e.preventDefault()
    target = e.currentTarget
    $(target).attr('disabled', true)

    conditional = $(target).closest('.conditional')
    mapping_id = $(conditional).find('.hideme .mapping-id').val()

    user_id = $(target).closest("form#form-policy-member-settings").find("button.btn-update-policy-member-settings").attr('data-user-id')
    
    if mapping_id
      $.ajax({
        url: '/users/' + user_id
        type: "DELETE",
        dataType: 'JSON',
        data: {
          mapping_id: mapping_id
        },
        success: (res) ->
          FinlyF.snapNotify(res.messages)
          if res.success == true
            $(conditional).remove()
          else
            $(target).attr('disabled', false)
        error: (err) ->
          console.log "Error", err
          $(target).attr('disabled', false)
      })
    else
      $(conditional).remove()


  clearDiv: (e) ->
    target = e.currentTarget
    $(target).html("")