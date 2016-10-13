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

  initialize: (options) ->
    @params = options.params
    @page = options.page
    @parent = options.parent

    if @page == 'user'
      @model = new FinlyF.Models.User({id: options.model_id})
      @model.fetch({
        data: @params
      })
      @model.on('sync', @populateDetails, @)

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

  edit: (e) ->
    target = $(e.currentTarget)
    container = $(target).closest('section')
    $(container).find('.item-attr-preview').addClass('hide')
    $(container).find('.item-attr-edit').addClass('show')


    #edit

    #change edit button to update
    $(target).addClass('success btn-update-user').removeClass('warning btn-edit-user').text('Update')

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
          console.log "now it will fetch ", _this.params.view
          _this.model.fetch({
            data: {
              view: _this.params.view
            }
          })
      error: (err) ->
        console.log "Err", err
    }) 


  update: (e) ->
    _this = @
    e.preventDefault()
    target = $(e.currentTarget)
    form = $(target).closest('section').find('form')
    values = {}
    $(form).find(':disabled').removeAttr('disabled');
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
          if parseInt($("#current_user_id").val()) == parseInt(_this.model.get('id'))
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
    url = $(target).attr('data-url')
    type = $(target).attr('data-method')
    data = {}
    data_presence = $(target).attr('data-presence')
    if data_presence
      data.type = $(target).attr('data-type')
      if $(target).attr('data-state-active')
        if $(target).attr('data-state-active') == 'true'
          data.active = true
        else
          data.active = false
    else
      data = {}

    data.view = @params.view

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
      error: (err) ->
        console.log "Err", err.messages
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

  prepareCardAction: (e) ->
    e.preventDefault()
    _this = @

    target = e.currentTarget
    action_type = $(target).attr('data-card-action-type')
    # modal = ("#modal-mp")
    modal = ("#modal-sub-mp")

    $(modal).modal('show')

    if action_type == 'load'
      $(modal).html(@templateLoadFunds())
    else if action_type == 'unload'
      $(modal).html(@templateUnloadFunds())


    #Getting the card balance in modal
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
        $(modal).find('.card-balance').html("&#8377;&nbsp;&nbsp;" + res.balance)
      error: (err) ->
        console.log "Error", err
    })

    # $.ajax

  cardAction: (e) ->
    e.preventDefault()
    _this = @
    target = e.currentTarget
    $(target).html("<i class='fa fa-spinner fa-spin'></i>").attr("disabled", true)

    action_type = $(target).attr('data-card-action-type')
    modal = $(@el).find('#modal-sub-mp')
    form = $(target).closest('.modal-body')


    amount = $(modal).find("input[name=amount]").val()
    password = $(modal).find("input[name=password]").val()

    $.ajax({
      url: '/cards/update_balance'
      type: "POST",
      dataType: 'json',
      data: {
        view: _this.params.view
        authenticity_token: $("#authenticity_token").val()
        to_user_id: _this.model.get('id')
        amount: amount
        password: password
        action_type: action_type
      },
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          $(modal).modal('hide')
          $(modal).html("")
        else
          console.log res
          $(target).attr("disabled", true)
      error: (err) ->
        console.log "Error", err

    })

  prepareCardStatus: (e) ->
    e.preventDefault()
    target = e.currentTarget
    _this = @

    modal = $("#modal-sub-mp")
    status = $(target).attr('data-card-status-type')

    $(modal).modal('show')
    $(modal).html(@templateCardStatus({status: status}))

  cardStatus: (e) ->
    e.preventDefault()
    _this = @
    target = e.currentTarget

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
        else
          console.log res
      error: (err) ->
        console.log "Error", err

    })

  requestCardBalance: (e) ->
    _this = @
    e.preventDefault()
    target = e.currentTarget

    $(target).html("Requesting&nbsp;&nbsp;&nbsp;<i class='fa fa-spinner fa-pulse'></i>")

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
        $(target).html("Update Balance")
        $(target).closest(".card-balance").find(".balance").html("&#8377;&nbsp;&nbsp;" + res.balance)
      error: (err) ->
        console.log "Error", err
        $(target).html("Request Balance")
    })


#Features
# 1. Compare models if anything has changed. Or else hide the show button.