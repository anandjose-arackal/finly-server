class FinlyF.Views.User extends Backbone.View
  templateList: HandlebarsTemplates['finlyf/users/crud/userList']
  template: HandlebarsTemplates['finlyf/users/crud/userSettlements']
  templateShow: HandlebarsTemplates['finlyf/users/crud/show']
  templateAddCondition: HandlebarsTemplates['finlyf/users/crud/addCondition']
  templateLoadFunds: HandlebarsTemplates['finlyf/users/card/modalLoadFunds']
  templateUnloadFunds: HandlebarsTemplates['finlyf/users/card/modalUnloadFunds']
  templateCardStatus: HandlebarsTemplates['finlyf/users/card/modalConfirmCardStatus']
  # templateShowDetails: HandlebarsTemplates['finlyf/users/crud/showDetails']
  # templateShow: HandlebarsTemplates['finlyf/reports/crud/show']
  # templateShowDetails: HandlebarsTemplates['finlyf/reports/crud/show_details']
  templateModalConfirmWithPW: HandlebarsTemplates['finlyf/users/actions/modalConfirmWithPW']

  className: 'user col-md-12'

  events:
    'click .btn-edit-user': 'edit'
    'click .btn-update-user': 'update'
    'click .btn-edit-policy': 'editPolicy'
    'click .btn-update-policy': 'updatePolicy'
    'click .btn-add-condition': 'newCondition'
    'click .btn-remove-condition': 'removeCondition'
    'click .btn-user-action': 'userAction'
    'click .btn-card-request-balance': 'requestCardBalance'
    'click .btn-card-action': 'prepareCardAction'
    'click .btn-confirm-card-action': 'cardAction'

    'click .btn-card-update-status': 'prepareCardStatus'
    'click .btn-confirm-card-status': 'cardStatus'
    'click ul.user-tab-panes li': 'changeActiveTab'

    'change input[type=radio].auto-submit-enabled': 'toggleAutoSubmitFields'

    'click .btn-edit-auto-submit': 'editAutoSubmit'
    'click .btn-update-auto-submit': 'updateAutoSubmit'

    # Activating employee without email
    'click .btn-active-employee': 'activateEmployee'

    # 'shown.bs.modal #modal-import-employees': 'addAuthKey'

  initialize: (options) ->
    @params = options.params
    @page = options.page
    @parent = options.parent
    @active_tab = @active_tab || '#tab-user-details'

    if @page == 'user'
      @model = new FinlyF.Models.User({id: options.model_id})
      @model.fetch({
        data: @params
      })
      @model.on('sync', @populateDetails, @)

    @userActionData = {
      data: {}
    } #Saving user information before user action

  render: ->
    switch @page
      when 'users'
        $(@el).attr('data-item-id', @model.get('id'))
        $(@el).html(@templateList({ item: @model.toJSON() }))
      when 'user'
        $(@el).removeClass('user').addClass('user-details no-padding')
        # $(@el).html(@templateShow({ item: @model.toJSON()}))
      when 'settlements'
        $(@el).attr('data-item-id', @model.get('id'))
        $(@el).html(@template({ item: @model.toJSON() }))
    @

  populateDetails: ->
    # console.log "here we are in after sync"
    # console.log @model.toJSON()
    $(@el).html(@templateShow({item: @model.toJSON()}))
    FinlyF.stopMainLoader(@el)
    # console.log("Active Tab: ", @active_tab)
    # $(@el).find(@active_tab).tab('show')
    $(@el).find('a[href="' + @active_tab + '"]').tab('show')
    @toggleAutoSubmitFields()
    @requestCardBalance()


  changeActiveTab: (e) ->
    target = $(e.currentTarget).find('a')
    new_active_tab = $(target).attr('href')
    @active_tab = new_active_tab



  edit: (e) ->
    target = $(e.currentTarget)
    container = $(target).closest('section')
    $(container).find('.item-attr-preview').addClass('hide')
    $(container).find('.item-attr-edit').addClass('show')


    #edit

    #change edit button to update
    $(target).addClass('success btn-update-user').removeClass('warning btn-edit-user').text('Update')

  editAutoSubmit: (e) ->
    target = $(e.currentTarget)
    container = $(target).closest('section')
    $(container).find('.item-attr-preview').addClass('hide')
    $(container).find('.item-attr-edit').addClass('show')
    #edit

    #change edit button to update
    $(target).addClass('btn-success btn-update-auto-submit').removeClass('btn-warning btn-edit-auto-submit').text('Update')

  editPolicy: (e) ->
    target = $(e.currentTarget)
    policy = $(target).closest('.policy')
    $(policy).find('.item-attr-preview').addClass('hide')
    $(policy).find('.item-attr-edit').addClass('show')

    selects = $(policy).find("select.item-attr-edit")
    for select in selects
      $(select).val($(select).attr('data-default-value'))
    # console.log selects.length 
    #edit

    #change edit button to update
    $(target).addClass('btn-success btn-update-policy').removeClass('btn-warning btn-edit-policy').html("<i class='fa fa-check-circle'></i>&nbsp;&nbsp;Update")

  updatePolicy: (e) ->
    _this = @
    e.preventDefault()
    target = $(e.currentTarget)
    $(target).attr('disabled', true).html("&nbsp;&nbsp;<i class='fa fa-spinner fa-spin'></i>&nbsp;&nbsp;")
    policy = $(target).closest('.policy')
    form = $(policy).find('form')
    values = {}

    # _.each($(container).find('form').serializeArray(), (input) ->
    _.each($(form).serializeArray(), (input) ->
      values[ input.name ] = input.value
    )
    # console.log values
    # values.authenticity_token = $("#authenticity_token").val()

    # # console.log values
    model = new FinlyF.Models.User({id: @model.get('id')})
    model.save(values, {
      data: values,
      processData: true
      success: (model, res) ->
        FinlyF.snapNotify(res.messages)
        # console.log res
        if res.success == true
          # console.log "now it will fetch ", _this.params.view

          $(target).removeAttr('disabled').html("<i class='fa fa-check-circle'></i>&nbsp;&nbsp;Update")
          _this.model.fetch({
            data: {
              view: _this.params.view
            }
          })
        else
          $(target).removeAttr('disabled').html("<i class='fa fa-check-circle'></i>&nbsp;&nbsp;Update")
      error: (err) ->
        console.log "Err", err
        $(target).removeAttr('disabled').html("<i class='fa fa-check-circle'></i>&nbsp;&nbsp;Update")
    }) 


  update: (e) ->
    _this = @
    e.preventDefault()
    target = $(e.currentTarget)
    form = $(target).closest('section').find('form')
    values = {}
    $(form).find(':disabled').removeAttr('disabled')
    # _.each($(container).find('form').serializeArray(), (input) ->
    _.each($(form).serializeArray(), (input) ->
      values[ input.name ] = input.value
    )
    values.view = @params.view
    # console.log values
    # values.authenticity_token = $("#authenticity_token").val()

    # # console.log values
    model = new FinlyF.Models.User({id: @model.get('id')})
    model.save(values, {
      data: values,
      processData: true
      success: (model, res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          if parseInt($("#current_user_id").val()) == parseInt(_this.model.get('id')) && $(target).attr('data-refresh-page') == 'true'
            #REFRESH THE ENTIRE PAGE IF CURRENT USER MODIFIED HIS ROLES
            flag = confirm("You have changed your roles. You need to reload the page.")
            if flag
              window.location.reload()
            else
              alert("Some functionality might not work unless page has been completely reloaded.")
              _this.model.fetch({
                data: {
                  view: _this.params.view
                }
              })
          else 
            _this.model.fetch({
              data: {
                view: _this.params.view
              }
            })
      error: (err) ->
        console.log "Err", err
    })



  updateAutoSubmit: (e) ->
    _this = @
    e.preventDefault()
    target = $(e.currentTarget)
    $(target).html("&nbsp;&nbsp;<i class='fa fa-spinner fa-spin'></i>&nbsp;&nbsp;").attr('disabled', true)
    form = $(target).closest('section').find('form')
    values = {}

    _.each($(form).serializeArray(), (input) ->
      values[ input.name ] = input.value
    )
    values.view = @params.view

    model = new FinlyF.Models.User({id: @model.get('id')})
    model.save(values, {
      data: values,
      processData: true
      success: (model, res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          _this.model.fetch({
            data: {
              view: _this.params.view
            }
          })
        else
          $(target).html("Update").removeAttr('disabled')
      error: (err) ->
        console.log "Err", err
        $(target).html("Update").removeAttr('disabled')
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

    item = {
      # condition_serial: Math.max.apply(Math,arr) + 1
      policy_id: $(target).attr('data-policy-id')
      manager_type: $(target).attr('data-manager-type')
      managers: _this.model.get('team_managers')
      finance_managers: _this.model.get('team_finance_managers')
    }
    if arr.length == 0
      item.condition_serial = 1
    else
      item.condition_serial = Math.max.apply(Math,arr) + 1

    # console.log item

    # console.log item
    $(target).closest('.add-condition').before(@templateAddCondition({item: item}))

  removeCondition: (e) ->
    e.preventDefault()
    target = e.currentTarget

    conditional = $(target).closest('.conditional')
    mapping_id = $(conditional).find('.hideme .mapping-id').val()

    if mapping_id
      $.ajax({
        url: '/users/' + @model.get('id')
        type: "DELETE",
        dataType: 'JSON',
        data: {
          mapping_id: mapping_id
        },
        success: (res) ->
          FinlyF.snapNotify(res.messages)
          console.log "Deleted it perhaps", res
          $(conditional).remove()
        error: (err) ->
          console.log "Error", err
      })
    else
      $(conditional).remove()

  userAction: (e) ->
    _this = @
    target = e.currentTarget

    button_text = $(target).text()
    url = $(target).attr('data-url')
    type = $(target).attr('data-method')
    data = {}
    data.type = $(target).attr('data-type')

    data.view = @params.view
    data_presence = $(target).attr('data-presence') 
    if data_presence == "true" #For activating and deactivating users only
      if $(target).attr('data-require-password') == "true"
        item = {}
        if $(target).attr('data-state-active')
          if $(target).attr('data-state-active') == 'true'
            data.active = true
            item.action_type = "Activate"#REF==4I
          else
            data.active = false
            item.action_type = "Deactivate"

          item.user = {
            name: @model.get('user').name
          }

          @userActionData.data = data
          @userActionData.url = url
          @userActionData.type = type
          # Show up password confirmation modal
          @confirmWithPW(item)
      else
        $(target).html("&nbsp;&nbsp;<i class='fa fa-spinner fa-spin'></i>&nbsp;&nbsp;").attr("disabled", true)
        $.ajax({
          url: url,
          type: type,
          data: data,
          dataType: 'json',
          success: (res) ->
            # console.log "Suc", res
            FinlyF.snapNotify(res.messages)
            if res.success == true
              _this.parent.trigger('refresh')
              # _this.model.fetch({
              #   view: _this.params.view
              # })
            else
              $(target).html(button_text).removeAttr("disabled")
          error: (err) ->
            console.log "Err", err.messages
            $(target).html(button_text).removeAttr("disabled")
        })
    else
      $(target).html("&nbsp;&nbsp;<i class='fa fa-spinner fa-spin'></i>&nbsp;&nbsp;").attr("disabled", true)
        
      $.ajax({
        url: url,
        type: type,
        data: data,
        dataType: 'json',
        success: (res) ->
          # console.log "Suc", res
          FinlyF.snapNotify(res.messages)
          if res.success == true
            _this.parent.trigger('refresh')
            # _this.model.fetch({
            #   view: _this.params.view
            # })
          else
            $(target).html(button_text).removeAttr("disabled")
        error: (err) ->
          console.log "Err", err.messages
          $(target).html(button_text).removeAttr("disabled")
      })
    # # console.log "working"
    # target = e.currentTarget
    # url = $(target).attr('data-url')
    # # type = 'state'

    # data = {
    #   type: 'state'
    #   user: {
    #     active: active
    #   }
    #   view: @params.view
    # }

    # $.ajax({
    #   url: url
    #   data: data
    #   dataType: 'json'
    #   type: "PUT"
    #   success: (res) ->
    #     console.log "Success", res
    #   error: (err) ->
    #     console.log "Err", err
    # })

  confirmWithPW: (item) ->
    modal = $("#modal-confirm-with-password")
    $(modal).modal('show')

    if item.action_type == "Activate"  #REF==4O
      $(modal).find('.modal-title').text("Activate User")
    else if item.action_type == "Deactivate"
      $(modal).find('.modal-title').text("Deativate User")


    _this = @
    $(modal).find(".activate-with-password-template").html(@templateModalConfirmWithPW({item: item}))
    $(modal).find(".btn-confirm-with-pw").on('click', (e) ->
      e.preventDefault()
      target = e.currentTarget
      button_text = $(target).text()

      $(target).html("&nbsp;&nbsp;<i class='fa fa-spinner fa-spin'></i>&nbsp;&nbsp;").attr("disabled", true)

      password = $(modal).find("input[type=password]").val()
      data = _this.userActionData.data
      data.password = password
      url = _this.userActionData.url
      type = _this.userActionData.type

      $.ajax({
        url: url,
        type: type,
        data: data,
        dataType: 'json',
        success: (res) ->
          # console.log "Suc", res
          FinlyF.snapNotify(res.messages)
          if res.success == true
            $(modal).modal('hide')
            _this.parent.trigger('refresh')
            # _this.model.fetch({
            #   view: _this.params.view
            # })
          else
            $(target).html(button_text).removeAttr("disabled")
        error: (err) ->
          $(target).html(button_text).removeAttr("disabled")
          console.log "Err", err.messages
      })
    )

  prepareCardAction: (e) ->
    e.preventDefault()
    _this = @

    target = e.currentTarget
    target_user = _this.model.get('user')
    item = {
      type: $(target).attr('data-action-type')
      url: $(target).attr('data-url')
      target_user_name: target_user.name
    }
    action_type = $(target).attr('data-action-type')
    # modal = ("#modal-mp")
    modal = $(@el).find("#modal-sub-mp")

    $(modal).modal('show')

    switch action_type
      when 'credit_wallet_from_virtual_account'
        $(modal).html(@templateLoadFunds({item: item}))
        $.ajax({
          url: 'users/' + _this.model.get('id') + '/balance'
          data: {
            view: _this.params.view
            target_user_wallet: true
            virtual_account: true
          }
          type: 'get',
          dataType: 'json'
          success: (res) ->
            # console.log res
            $(modal).find('.virtual_account_balance').html("&#8377;&nbsp;" + res.virtual_account)
            $(modal).find('.target_user_wallet_balance').html("&#8377;&nbsp;" + res.target_user_wallet)
        })
      when 'credit_card_from_virtual_account'
        $(modal).html(@templateLoadFunds({item: item}))
        $.ajax({
          url: 'users/' + _this.model.get('id') + '/balance'
          data: {
            view: _this.params.view
            target_user_card: true
            virtual_account: true
          }
          type: 'get',
          dataType: 'json'
          success: (res) ->
            # console.log res
            $(modal).find('.virtual_account_balance').html("&#8377;&nbsp;" + res.virtual_account)
            $(modal).find('.target_user_card_balance').html("&#8377;&nbsp;" + res.target_user_card)
        })
      when 'credit_wallet_from_wallet'
        $(modal).html(@templateLoadFunds({item: item}))
        $.ajax({
          url: 'users/' + _this.model.get('id') + '/balance'
          data: {
            view: _this.params.view
            target_user_wallet: true
            current_user_wallet: true
          }
          type: 'get',
          dataType: 'json'
          success: (res) ->
            # console.log res
            $(modal).find('.current_user_wallet_balance').html("&#8377;&nbsp;" + res.current_user_wallet)
            $(modal).find('.target_user_wallet_balance').html("&#8377;&nbsp;" + res.target_user_wallet)
        })
      when 'credit_card_from_wallet'
        $(modal).html(@templateLoadFunds({item: item}))
        $.ajax({
          url: 'users/' + _this.model.get('id') + '/balance'
          data: {
            view: _this.params.view
            target_user_card: true
            current_user_wallet: true
          }
          type: 'get',
          dataType: 'json'
          success: (res) ->
            # console.log res
            $(modal).find('.current_user_wallet_balance').html("&#8377;&nbsp;" + res.current_user_wallet)
            $(modal).find('.target_user_card_balance').html("&#8377;&nbsp;" + res.target_user_card)
        })
      when 'debit_wallet_to_virtual_account'
        $(modal).html(@templateUnloadFunds({item: item}))
        $.ajax({
          url: 'users/' + _this.model.get('id') + '/balance'
          data: {
            view: _this.params.view
            target_user_wallet: true
            virtual_account: true
          }
          type: 'get',
          dataType: 'json'
          success: (res) ->
            # console.log res
            $(modal).find('.virtual_account_balance').html("&#8377;&nbsp;" + res.virtual_account)
            $(modal).find('.target_user_wallet_balance').html("&#8377;&nbsp;" + res.target_user_wallet)
        })
      when 'debit_wallet_to_wallet'
        $(modal).html(@templateUnloadFunds({item: item}))
        $.ajax({
          url: 'users/' + _this.model.get('id') + '/balance'
          data: {
            view: _this.params.view
            target_user_wallet: true
            current_user_wallet: true
          }
          type: 'get',
          dataType: 'json'
          success: (res) ->
            # console.log res
            $(modal).find('.current_user_wallet_balance').html("&#8377;&nbsp;" + res.current_user_wallet)
            $(modal).find('.target_user_wallet_balance').html("&#8377;&nbsp;" + res.target_user_wallet)
        })
      
    
    # if action_type == 'credit_card_from_virtual_account' || action_type == 'credit_card_from_wallet' || 
    #   $(modal).html(@templateLoadFunds({item: item}))
    # else if action_type == 'debit_card_to_company_credits' || action_type == 'debit_card_to_card'
    #   $(modal).html(@templateUnloadFunds({item: item}))


    #Getting the card balance in modal
    # $.ajax({
    #   url: '/cards/details',
    #   dataType: 'json',
    #   type: "POST",
    #   data: {
    #     authenticity_token: $("#authenticity_token").val()
    #     user_id: _this.model.get('id')
    #     view: _this.params.view
    #   }
    #   success: (res) ->
    #     $(modal).find('.card-balance').html("&#8377;&nbsp;&nbsp;" + res.balance)
    #   error: (err) ->
    #     console.log "Error", err
    # })

    # $.ajax

  cardAction: (e) ->
    e.preventDefault()
    _this = @
    target = e.currentTarget
    $(target).html("<i class='fa fa-spinner fa-spin'></i>").attr("disabled", true)
    url = $(target).attr('data-url')

    action_type = $(target).attr('data-action-type')
    modal = $(@el).find('#modal-sub-mp')
    form = $(target).closest('.modal-body')




    amount = $(modal).find("input[name=amount]").val()
    password = $(modal).find("input[name=password]").val()
    data = {
      view: _this.params.view
      authenticity_token: $("#authenticity_token").val()
      # to_user_id: _this.model.get('id')
      amount: amount
      password: password
      # action_type: action_type
    }

    if action_type == 'credit_wallet_from_virtual_account' || action_type == 'credit_card_from_card'
      data.to_user_id = _this.model.get('id')
    else if action_type == 'debit_card_to_company_credits' || action_type == 'debit_card_to_card'
      data.from_user_id = _this.model.get('id')

    switch action_type
      when 'credit_wallet_from_virtual_account', 'credit_card_from_virtual_account', 'credit_wallet_from_wallet', 'credit_card_from_wallet'
        data.to_user_id = _this.model.get('id')
      when 'debit_wallet_to_virtual_account', 'debit_wallet_to_wallet'
        data.from_user_id = _this.model.get('id')
    

    $.ajax({
      url: url
      type: "POST",
      dataType: 'json',
      data: data,
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          $(modal).modal('hide')
          $(modal).html("")
          #Update current card balance.
          # $(_this.el).find(".card-balance").find(".balance").html("&nbsp;")
          # $(_this.el).find(".btn-card-request-balance").text("Request Balance")
          _this.model.fetch({
            data: {
              view: _this.params.view
            }
          })
        else
          # console.log res
          $(target).html("Transfer").attr("disabled", false)
      error: (err) ->
        console.log "Error", err
        $(target).html("Transfer").attr("disabled", false)

    })

  prepareCardStatus: (e) ->
    e.preventDefault()
    target = e.currentTarget
    _this = @

    status = $(target).attr('data-card-status-type')
    if parseInt(status) == 0
      title = "Block Card"
    else if parseInt(status) == 1
      title = "Unblock Card"


    modal = $("#modal-sub-mp")
    data = {
      status: status
      title: title
    }

    $(modal).modal('show')
    $(modal).html(@templateCardStatus({item: data}))

  cardStatus: (e) ->
    e.preventDefault()
    _this = @
    target = e.currentTarget
    $(target).attr('disabled', true)

    status_type = $(target).attr('data-card-status-type')
    modal = $(@el).find('#modal-sub-mp')
    form = $(target).closest('.modal-body')


    password = $(modal).find("input[name=password]").val()

    $.ajax({
      url: '/cards/update_status'
      type: "POST",
      dataType: 'json',
      data: {
        view: _this.params.view
        authenticity_token: $("#authenticity_token").val()
        user_id: _this.model.get('id')
        password: password
        status_type: status_type
      },
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          $(modal).modal('hide')
          $(modal).html("")
          _this.model.fetch({
            data: {
              view: _this.params.view
            }
          })
        else
          $(target).attr('disabled', false)
          console.log res
      error: (err) ->
        console.log "Error", err
        $(target).attr('disabled', false)

    })

  requestCardBalance: (e) ->
    _this = @

    if e
      e.preventDefault()
      target = e.currentTarget
      $(target).addClass('fa-pulse')
      # $(target).html("Requesting&nbsp;&nbsp;&nbsp;<i class='fa fa-spinner fa-pulse'></i>")

    card_balance_div = $(@el).find('.card-balance')

    $.ajax({
      url: '/cards/details',
      dataType: 'json',
      type: "POST",
      data: {
        authenticity_token: $("#authenticity_token").val()
        user_id: _this.model.get('id')
        view: _this.params.view
      }
      success: (res) ->
        # console.log "Success", res
        $(card_balance_div).find('.balance').html("&#8377;&nbsp;&nbsp;" + res.balance)
        $(card_balance_div).find('.btn-card-request-balance').removeClass('fa-spinner fa-pulse').addClass('fa-refresh')
        $(target).removeClass('fa-pulse')
      error: (err) ->
        console.log "Error", err

        # $(target).html("Request Balance")
    })

  toggleAutoSubmitFields: (e) ->
    auto_submit_div = $(@el).find("#tab-user-auto-submit-report")
    auto_submit_fields_div = $(auto_submit_div).find('.row.auto-submit-fields')
    auto_submit_disabled_message = $(auto_submit_div).find('.auto-submit-disabled-message')
    if e
      target = e.currentTarget
    else
      target = $(auto_submit_div).find('input.auto-submit-enabled:checked')
      # console.log target

    if parseInt($(target).val()) == 0
      # $(auto_submit_fields_div).find('.item-attr-edit').attr('disabled', true)
      $(auto_submit_fields_div).slideUp('slow')
      $(auto_submit_disabled_message).slideDown()
    else
      # $(auto_submit_fields_div).find('.item-attr-edit').removeAttr('disabled')
      $(auto_submit_fields_div).slideDown('slow')
      $(auto_submit_disabled_message).slideUp()

  # Activating employees without email
  activateEmployee: (e) ->
    modal = $('#modal-activate-employee')
    $(modal).html("")
    if e
      e.preventDefault()
      target = e.currentTarget

      # $(target).attr('disabled', true)
      $(modal).modal('show')

    _this = @
    user_id = @model.get('id')


    # Issue -> datepicker change year & month featuer were not working inside modal
    enforceModalFocusFn = $.fn.modal.Constructor.prototype.enforceFocus
    $.fn.modal.Constructor.prototype.enforceFocus = ->
    $(modal).on('hidden.bs.modal', ->
      $.fn.modal.Constructor.prototype.enforceFocus = enforceModalFocusFn
    )
    # Issue ends

    $.ajax({
      url: '/pending_invites/activate_employee'
      data: {
        user_id: user_id
      },
      dataType: 'html',
      success: (res) ->
        $(modal).html(res)
        if e
          # console.log "an event is present."
          if $(modal).find("input[name=activate_employee_with_details]").length
            # console.log $(modal).find("input[name=activate_employee_with_deatils]").html()
            # console.log "will attach signup event"
            _this.attachSignUpEvent(modal)
          else
            # console.log "will attach verification event"
            _this.attachVerifyEvent(modal)
            _this.attachOPTTimerEvent(modal)
        else
          # console.log "will attach signup event"
          _this.attachSignUpEvent(modal)

      error: (err) ->
        console.log "Err", err
    })

  attachVerifyEvent: (modal) ->
    _this = @
    # Manually attaching even since modal is outside view's el
    $(modal).find(".btn-verify").on('click', (e) ->
      e.preventDefault()
      $.ajax({
        url: "/otp/verify",
        type: "POST",
        dataType: "json",
        data: {
          user_id: _this.model.get('id'),
          authenticity_token: $("#authenticity_token").val(),
          verification_code: $("#user_otp").val()
        },
        success: (res) ->
          FinlyF.snapNotify(res.messages)
          if res.success == true
            # $(modal).modal('hide')
            _this.activateEmployee()

          # else
          #   console.log("Error")
        error: (err) ->
          console.log("Err", err)
      })
    )

    # $(modal).on('shown.bs.modal', (e) ->

    # )

  attachOPTTimerEvent: (modal) ->
    _this = @

    $(modal).find(".btn-send-otp").on('click', (e) ->
      # $(this).attr('disabled', true).html("<i class='fa fa-check-o'></i>&nbsp;&nbsp;OTP Sent");
      e.preventDefault()
      target = e.currentTarget
      $(target).attr('disabled', true).html("&nbsp;&nbsp;<i class='fa fa-spin fa-spinner'></i>&nbsp;&nbsp;")
      # e.preventDefault();
      $.ajax({
        url: "/pending_invites/send_otp"
        dataType: "JSON"
        # // type: "POST",
        data: {
          user_id: $(modal).find("form").attr('data-user-id'),
          authenticity_token: $("#authenticity_token").val()
        },
        success: (res) ->
          if res.success == true
            $(target).attr('disabled', true).html("<i class='fa fa-check-o'></i>&nbsp;&nbsp;OTP Sent")
            FinlyF.snapNotify(res.messages)
            $(modal).find('.resend-otp').removeClass('hidden')
            # Timer.startTimer()
            _this.otpTimer(modal)

          
          # // console.log("Success", res);
        error: (err) ->
          console.log("Error", err)
      })
    )

    $(modal).find(".resend-otp").on('click', (e) ->
      e.preventDefault()
      $.ajax({
        url: "/otp/resend"
        dataType: "JSON"
        type: "POST"
        data: {
          user_id: $(modal).find("form").attr('data-user-id'),
          authenticity_token: $("#authenticity_token").val()
        },
        success: (res) ->
          FinlyF.snapNotify(res.messages)
          # console.log("Success", res)
          _this.otpTimer(modal)
        error: (err) ->
          console.log("Error", err)
      })
    )

  otpTimer: (modal) ->
    # console.log "Starting timer"
    if @otptimer
      clearInterval(@otptimer)
    _this = @
    button = $(modal).find('.resend-otp')
    @otptimer_time = 59
    $(button).html("Resend OTP In: <span>00:59</span>").removeClass('btn-success').addClass('btn-default')
    @otptimer = setInterval( ->
      # $(button).attr('disabled', 'disabled')
      if _this.otptimer_time == 0
        _this.otptimer_terminate(button)
      if _this.otptimer_time.toString().length == 1
        $(button).find('span').text("00:0" + _this.otptimer_time.toString())
      else
        $(button).find('span').text("00:" + _this.otptimer_time.toString())
      _this.otptimer_time = _this.otptimer_time - 1
    , 1000)

  otptimer_terminate: (button) ->
    $(button).attr('disabled', false).html("Resend OTP").addClass('btn-success')
    clearInterval(@otptimer)

    # startTimer: function(){
    #   console.log("starting timer");
    #   $(this.button).html("Resend OTP In: <span>00:00</span>").removeClass("btn-success").addClass('btn-default')
    #   _this = this;
    #   this.time = 60;
    #   this.timer = setInterval(function(){
    #     $(_this.button).attr('disabled', 'disabled');
    #     // console.log("Time is", _this.time);
    #     if(_this.time === 0){
    #       _this.showResend();
    #     }
    #     if(_this.time.toString().length == 1){
    #       $(_this.button).find('span').text("00:0" + _this.time.toString());
    #     } else {
    #       $(_this.button).find('span').text("00:" + _this.time.toString());
    #     }
    #     _this.time = _this.time - 1;
    #   }, 1000);
    # },

  attachSignUpEvent: (modal) ->
    console.log "Attaching Event", $(modal).find("#submitButton")
    _this = @

    $(modal).find("#submitButton").on('click', (e) ->
      e.preventDefault()
      console.log "button was clicked."
      target = e.currentTarget
      $(target).attr('disabled', true).html("&nbsp;&nbsp;<i class='fa fa-spinner fa-spin'></i>&nbsp;&nbsp;")
      $.ajax({
        url: $(modal).find('#newUserRegistration').attr('action')
        type: 'PATCH'
        data: $(modal).find('#newUserRegistration').serialize()
        success: (res) ->
          FinlyF.snapNotify(res.messages)
          if res.success == true
            $(modal).modal('hide')
            _this.parent.trigger('refresh')
          else
            $(target).removeAttr('disabled').text('Submit')
        error: (err) ->
          console.log "Err", err
          $(target).removeAttr('disabled').text('Submit')
      })
    )





#Features
# 1. Compare models if anything has changed. Or else hide the show button.
