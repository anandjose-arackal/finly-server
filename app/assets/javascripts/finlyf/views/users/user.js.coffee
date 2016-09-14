class FinlyF.Views.User extends Backbone.View
  templateList: HandlebarsTemplates['finlyf/users/crud/userList']
  template: HandlebarsTemplates['finlyf/users/crud/userSettlements']
  templateShow: HandlebarsTemplates['finlyf/users/crud/show']
  templateAddCondition: HandlebarsTemplates['finlyf/users/crud/addCondition']
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
    'click .btn-user-action': 'userAction'

  initialize: (options) ->
    @params = options.params
    @page = options.page

    if @page == 'user'
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
        $(@el).removeClass('user').addClass('user-details')
        # $(@el).html(@templateShow({ item: @model.toJSON()}))
      when 'settlements'
        $(@el).attr('data-item-id', @model.get('id'))
        $(@el).html(@template({ item: @model.toJSON() }))
    @

  populateDetails: ->
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
    $(target).addClass('success btn-update-policy').removeClass('warning btn-edit-policy').text('Update')

  updatePolicy: (e) ->
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
        console.log model, res
      error: (err) ->
        console.log "Err", err
    }) 


  update: (e) ->
    e.preventDefault()
    target = $(e.currentTarget)
    form = $(target).closest('section').find('form')
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
        console.log model, res
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
    console.log "count", conditionals.length
    for conditional in conditionals
      arr.push(parseInt($(conditional).attr('data-condition-serial')))

    item = {
      condition_serial: Math.max.apply(Math,arr) + 1
      policy_id: $(target).attr('data-policy-id')
      manager_type: $(target).attr('data-manager-type')
      managers: _this.model.get('company_managers')
    }

    # console.log item
    $(target).closest('.add-condition').before(@templateAddCondition({item: item}))

  userAction: (e) ->
    target = e.currentTarget
    url = $(target).attr('data-url')
    type = $(target).attr('data-method')
    data = {}
    data_presence = $(target).attr('data-presence')
    if data_presence
      data.type = $(target).attr('data-type')
    else
      data = {}

    $.ajax({
      url: url,
      type: type,
      data: data,
      dataType: 'json',
      success: (res) ->
        console.log "Suc", res
        FinlyF.snapNotify(res)
      error: (err) ->
        console.log "Err", err
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


#Features
# 1. Compare models if anything has changed. Or else hide the show button.