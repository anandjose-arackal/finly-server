class FinlyF.Views.Request extends Backbone.View
  templateSkeleton: HandlebarsTemplates['finlyf/requests/base/requestShowSkeleton']
  templateShowNavbar: HandlebarsTemplates['finlyf/requests/navbar/show/navbar']

  template: HandlebarsTemplates['finlyf/requests/crud/request']
  templateLoadingAnimation: HandlebarsTemplates['finlyf/base/loadingAnimation']
  templateShow: HandlebarsTemplates['finlyf/requests/crud/show']
  templateShowDetails: HandlebarsTemplates['finlyf/requests/crud/show_details']
  templateAddCategory: HandlebarsTemplates['finlyf/requests/crud/addRequestCategory']
  templateModalLoadFunds: HandlebarsTemplates['finlyf/requests/modalLoadFunds']

  templateApproveOptions: HandlebarsTemplates['finlyf/requests/actions/modalApproveOptions']

  className: 'item col-sm-12'

  events:
    'click .select-item': 'toggleSelect'
    # 'input [contenteditable=true]': 'updateModel'
    'click .add-new-expense': 'newExpense'
    'click .add-existing-expense': 'existingExpense'
    'click .btn-create-expense': 'createExpense'
    'click .btn-post-comment': 'postComment'

    'click .btn-delete-request': 'delete'
    'click .btn-confirm-delete-request': 'confirmDelete'
    'click .btn-edit-item': 'edit'
    'click .btn-update-item': 'update'
    # 'click .btn-submit-item': 'submit'
    # 'click .btn-retract-item': 'retract'

    # 'click .btn-delete-sub-item': 'deleteSub'
    # 'click .btn-view-sub-item': 'viewSub'
    # 'click .btn-reject-sub-item': 'rejectSub'
    'hidden.bs.modal #modal-mp': 'refreshData'
    'keypress .comment-content': 'postCommentByEnter'
    'click .btn-add-request-category': 'addRequestCategory'
    'click .btn-remove-request-category': 'removeRequestCategory'

    #reports
    # 'click .dropdown .btn': 'showDropDown'
    'click .btn-report-action': 'requestAction'
    'click .confirm-add-existing-expense': 'addExistingExpenses'

    #money requests actinos
    'click .btn-transfer': 'prepareTransfer'
    'click .btn-confirm-transfer': 'confirmTransfer'
    'click .btn-approve-forward-to': 'approveForwardTo'


    'click .btn-go-back': 'goBacktoPreviousPage'
    'click .btn-approve-options': 'approveOptions'
    'click #btnRejectRequest': 'processRejectRequest'
    'click .btn-confirm-reject-request': 'rejectRequest'



    'click #btnTakeControlRequest': 'processTakeControl'
    'click .btn-confirm-take-control': 'takeControl'


  initialize: (options) ->
    # console.log "here in requests"
    # @parent = options.parent
    _this = @
    data = {}

    if options
      @preview = options.preview
      @params = options.params || {}
      @current_view = options.view || @params.view || 'personal'
    if @preview
      @current_view = options.params.view ##NEED TO ADD THIS IN REPORTS
      if @current_view
        data.view = @current_view
      if @params.ref
        data.ref = @params.ref
      if @params.n_id
        data.n_id = @params.n_id
      $(@el).removeClass("item").addClass("bg-white no-padding")
      @model = new FinlyF.Models.Request({id: options.model_id})
      @model.fetch({data: data})
    @model.on('sync', @populateDetails, @)
    @model.on('change', @showSaveOption, @)
    # @on('expense:selected', @showExpenseSelectOption, @)#REF==3I
    

  render: ->
    unless @preview
      @model.set('view', @current_view)
      $(@el).html(@template({ item: @model.toJSON() }))
    else
      $(@el).html(@templateSkeleton())
      FinlyF.structureActions(@el, @params)
      # $(@el).find("#item-show-details").html(@templateLoadingAnimation())
    @

  updateModel: (e) ->
    # _this = @
    field = $(e.target).attr('data-field')
    value = e.target.innerText
    @model.set(field, value);

  toggleSelect: (e) ->
    if $(e.currentTarget).prop('checked')
      $(@el).addClass('selected')
    else
      $(@el).removeClass('selected')

  populateDetails: ->
    @model.set('current_view', @current_view)
    $(@el).find(".navbar-full").html(@templateShowNavbar({item: @model.toJSON()}))
    $(@el).find(".main").html(@templateShow({item: @model.toJSON()}))

    # $(@el).find("#item-show-details").html(@templateShowDetails({item: @model.toJSON()}))
    $(@el).find(".datepicker").datepicker({ dateFormat: "dd-mm-yy" })

  showSaveOption: ->
    $(".btn-update-item").css("display", "inline")

  addRequestCategory: (e) ->
    e.preventDefault()
    target = e.currentTarget

    container = $(target).closest('.add-request-category')

    data = {
      category: {
        name: $(container).find('select[name=category] option:selected').text()
        id: $(container).find('select[name=category]').val()
      }        
      amount: {
        value: $(container).find('input[name=amount_value]').val()
      }
    }


    # console.log data
    $(@el).find('.request-categories').append(@templateAddCategory({item: data}))

    $(container).find('select[name=category] option:selected').remove()

    $(@el).find('.btn-edit-item').addClass('btn-update-item btn-success').removeClass('btn-edit-item btn-warning').html("Update  <i class='fa fa-check'></i>")

    _this = @

    target_select = $(@el).find(".item-policy-edit")
    $(target_select).val($(target_select).attr('data-default-value'))

    $(@el).find('.item-attr-edit').css("display", "inline")
    $(@el).find('.item-attr-preview').css('display', 'none')

  removeRequestCategory: (e) ->
    e.preventDefault()
    target = e.currentTarget

    requset_category_dropdown = $(@el).find('.request-category-dropdown')
    container = $(target).closest('.request-category')

    option = $('<option />', {
      text: $(container).find('.request-category-name').text()
      value: $(container).find('.request-category-id').val()
    }).appendTo(requset_category_dropdown)

    # console.log $(container).find('.request-category-name').text(), $(container).find('.request-category-id').val()

    $(container).find('.request-category-amount-value').val(0)

    $(container).hide()




  edit: (e) ->
    e.preventDefault()
    target = e.currentTarget
    navbar_right = $(target).closest('.navbar-right')
    $(navbar_right).find('button.btn-report-action').attr('disabled', true)
    #Warning!!! Dirty codes ahead!
    $(e.currentTarget).addClass('btn-update-item btn-success').removeClass('btn-edit-item btn-warning').html("Update  <i class='fa fa-check'></i>")

    _this = @
    # $(@el).find(".item-name").html("<input type='text' class='item-name-edit' />")
    # $(@el).find(".item-name .item-name-edit").val(_this.model.get('name'))

    target_select = $(@el).find(".item-policy-edit")
    $(target_select).val($(target_select).attr('data-default-value'))

    $(@el).find('.item-attr-edit').css("display", "inline")
    $(@el).find('.item-attr-preview').css('display', 'none')

  update: (e) ->
    e.preventDefault()
    target = e.currentTarget
    # navbar_right = $(target).closest('.navbar-right')

    $(target).html("<i class='fa fa-circle-o-notch fa-spin'></i>").attr('disabled', true)
    # {
    #   money_request: {
    #     name: "Mumbai",
    #     required_by_date: date
    #     policy_id: 1
    #     memo: "Need it for to meet the client"
    #     items_attributes[
    #       {
    #         category_id: 1
    #         amount_attributes: {
    #           value: 50
    #           currency_id: 1
    #         }
    #       }
    #     ]
    #   }
    # }
    _this = @
    formData = new FormData($('form#edit-money-request')[0])
    payment_mode_id = $("form#edit-money-request select[name=money_request\\[payment_mode_id\\]] option:selected").val() || $("form#edit-money-request input[name=money_request\\[payment_mode_id\\]]").val()
    # console.log "payment_mode_id", payment_mode_id
    formData.append('money_request[payment_mode_id]', payment_mode_id)
    $.ajax({
      url: '/money_request/' + _this.model.get('id')
      type: "PUT",
      data: formData,
      dataType: 'json',
      success: (res) ->
        # console.log res.messages
        FinlyF.snapNotify(res.messages)
        if res.success == true
          # $(_this.parent.el).find("#item-details .close-item-details .close-details").attr("data-refresh-true", true)
          $("#modal-new").modal('hide')
          _this.model.fetch({
            data: {
              view: _this.current_view
            }
          })
        else
          $(target).removeAttr('disabled').text('Update')
      error: (err) ->
        console.log "Error", err 
        $(target).removeAttr('disabled').text('Update')
      cache: false,
      contentType: false,
      processData: false
    })

  postCommentByEnter: (e) ->
    if e.keyCode == 13
      $(e.currentTarget).closest('.form-new-comment').find('.btn-post-comment').click()
      return false

  postComment: (e) ->
    e.preventDefault()
    $(e.currentTarget).text('Posting...').attr('disabled', true)
    _this = @
    target = $(e.currentTarget)
    money_request_id = $(target).attr('data-item-id')
    data = {
      comment: $(target).closest('.form-new-comment').find('.comment-content').val()
    }

    # @model.set('comment', comment)
    model = new FinlyF.Models.Report(data)
    model.urlRoot = '/money_request/' + money_request_id + '/comment'
    # console.log _this.parent.params.view
    model.save({view: _this.current_view}, {
      success: (model, res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          _this.model.fetch({
            data: {
              view: _this.current_view
            }
          })
        else
          $(e.currentTarget).text('Post').attr('disabled', false)
      error: (err) ->
        console.log "Error", err
        $(e.currentTarget).text('Post')
    })
    # console.log report_id

  delete: (e) ->
    e.preventDefault()
    modal = $(@el).find("#modal-confirm-delete")
    $(modal).modal('show')

  confirmDelete: (e) ->
    e.preventDefault()
    _this = @

    target = e.currentTarget
    modal = $(target).closest('#modal-confirm-delete')


    # @model.set('authenticity_token', $("#authenticity_token").val())
    # console.log $("#authenticity_token").val()
    params = {
      view: @current_view
    }
    @model.destroy({
      data: {
        'authenticity_token': $("#authenticity_token").val()
      }
      processData: true
      success: (model, res) ->
        $(modal).modal('hide')

        # Hack for removing backdrop
        $('body').removeClass('modal-open')
        $('.modal-backdrop').remove()

        FinlyF.snapNotify(res.messages)

        FinlyF.primary_router.navigate('requests/params=' + JSON.stringify(params), {trigger: true})

        # console.log res
        # _this.parent.trigger('item:destroyed')
      error: (err) ->
        console.log "Error", err

    })

  requestAction: (e) ->
    # console.log "hi"
    e.preventDefault()
    target = e.currentTarget
    button_text = $(target).text()
    $(target).attr('disabled', true).html("&nbsp;&nbsp;<i class='fa-spin fa-spinner fa'></i>&nbsp;&nbsp;")
    _this = @
    url = $(e.currentTarget).attr('data-url')
    $.ajax({
      url: url,
      type: 'PATCH',
      dataType: 'json',
      data: {
        authenticity_token: $("#authenticity_token").val()
        type: $(e.currentTarget).attr('data-action-type')
      }
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          _this.model.fetch({
            data: {view: _this.current_view}
          })
        else
          $(target).removeAttr('disabled').html(button_text)
          # $(_this.parent.el).find("#item-details .close-item-details .close-details").attr("data-refresh-true", true)
          
      error: (err) ->
        console.log "Error", err
        $(target).removeAttr('disabled').html(button_text)
    })

  prepareTransfer: (e) ->
    _this = @
    e.preventDefault()

    target = e.currentTarget
    item = {
      url: $(target).attr("data-url")
      type: $(target).attr("data-action-type")
      amount: _this.model.get('total')
      target_user_name: _this.model.get('user_name')
    }
    
    modal = $(@el).find("#modal-mp")
    $(modal).html(@templateModalLoadFunds({item: item}))
    $(modal).modal('show')

    $.ajax({
      dataType: "json"
      type : 'get'
      # url: '/settlements/summary?view_to_load=payments&view=personal'
      url: '/users/' + _this.model.get('user_id') + '/balance'
      data:
        # target_user_id: user_id
        authenticity_token: $("#authenticity_token").val()
        current_user_wallet: true
        current_user_card: true
        target_user_card: true
        target_user_wallet: true
        virtual_account: true
        view: _this.current_view
      success: (data) ->
        $(modal).find('.current_user_wallet_balance').html("&#8377;&nbsp;" + data.current_user_wallet)
        $(modal).find('.target_user_card_balance').html("&#8377;&nbsp;" + data.target_user_card)
        $(modal).find('.virtual_account_balance').html("&#8377;&nbsp;" + data.virtual_account)
        $(modal).find('.target_user_wallet_balance').html("&#8377;&nbsp;" + data.target_user_wallet)
        $(modal).find('.current_user_card_balance').html("&#8377;&nbsp;" + data.current_user_card)
        $(modal).find('.current_user_card_eligibility').html("&#8377;&nbsp;" + data.current_user_card_details.available_card_eligibility)
        $(modal).find('.target_user_card_eligibility').html("&#8377;&nbsp;" + data.target_user_card_details.available_card_eligibility)
      error: (err) ->
        console.log err
    })

  confirmTransfer: (e) ->
    _this = @
    e.preventDefault()
    target = e.currentTarget
    $(target).attr('disabled', true).html("&nbsp;&nbsp;<i class='fa fa-spin fa-spinner'></i>&nbsp;&nbsp;")
    container = $(target).closest(".modal")

    url = $(target).attr("data-url")
    # action_type = $(target).attr("data-action-type")
    password = $(container).find('input[name=password]').val()
    amount = $(container).find('input[name=amount]').val()
    note = $(container).find('textarea[name=note]').val()

    modal = $(@el).find("#modal-mp")
    approveOptionsModal = $(@el).find("#modal-approve-options")

    $.ajax({
      url: url,
      type: "PATCH",
      dataType: 'json',
      data: {
        authenticity_token: $("#authenticity_token").val()
        # type: action_type,
        password: password,
        amount: amount,
        note: note,
        view: _this.current_view
      },
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          $(modal).modal('hide')
          $(approveOptionsModal).modal('hide')
          _this.model.fetch({
            data: {view: _this.current_view}
          })
          # $(_this.parent.el).find("#item-details .close-item-details .close-details").attr("data-refresh-true", true)
        else
          $(target).attr('disabled', false).html("Confirm Transfer")
          
      error: (err) ->
        console.log "Error", err
    })

  approveForwardTo: (e) ->
    e.preventDefault()

    approveOptionsModal = $(@el).find("#modal-approve-options")

    _this = @
    target = e.currentTarget
    url = $(target).attr('data-url')
    forward_to_user_id = $(target).attr("data-forward-to")
    $.ajax({
      url: url,
      type: "PATCH",
      dataType: 'json',
      data: {
        authenticity_token: $("#authenticity_token").val()
        type: $(target).attr("data-action-type")
        forward_to_user_id: forward_to_user_id
      }
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          $(approveOptionsModal).modal('hide')
          _this.model.fetch({
            data: {view: _this.current_view}
          })
          # $(_this.parent.el).find("#item-details .close-item-details .close-details").attr("data-refresh-true", true)
          
      error: (err) ->
        console.log "Error", err
    })

  processRejectRequest: (e) ->
    e.preventDefault()

    modal = $(@el).find('#modal-confirm-reject')
    $(modal).modal('show')

  rejectRequest: (e) ->
    e.preventDefault()
    target = e.currentTarget
    button_text = $(target).text()
    $(target).attr('disabled', true).html("&nbsp;&nbsp;<i class='fa-spin fa-spinner fa'></i>&nbsp;&nbsp;")
    _this = @


    origin_button = $("#btnRejectRequest")
    url = $(origin_button).attr("data-url")

    modal = $(target).closest('#modal-confirm-reject')

    data = {
      reject_note: $(modal).find("textarea.reject-note").val()
      type: $(origin_button).attr('data-action-type')
    }

    $.ajax({
      url: url,
      type: 'patch',
      dataType: 'json',
      data: data,
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          $(modal).modal('hide')
          _this.model.fetch({
            data: {view: _this.current_view}
          })
          # $(_this.parent.el).find("#item-details .close-item-details .close-details").attr("data-refresh-true", true)
        else
          $(target).removeAttr('disabled').html(button_text)
          # _this.model.fetch({
          #   data: {view: _this.current_view}
          # })
        
      error: (err) ->
        console.log "error", err
        $(target).removeAttr('disabled').html(button_text)
    })

  processTakeControl: (e) ->
    e.preventDefault()

    modal = $(@el).find('#modal-confirm-take-control')
    $(modal).modal('show')

  takeControl: (e) ->
    e.preventDefault()
    target = e.currentTarget
    button_text = $(target).text()
    $(target).attr('disabled', true).html("&nbsp;&nbsp;<i class='fa-spin fa-spinner fa'></i>&nbsp;&nbsp;")
    _this = @


    origin_button = $("#btnTakeControlRequest")
    url = $(origin_button).attr("data-url")

    modal = $(target).closest('#modal-confirm-take-control')

    data = {
      take_control_note: $(modal).find("textarea.take-control-note").val()
      type: $(origin_button).attr('data-action-type')
    }

    $.ajax({
      url: url,
      type: 'patch',
      dataType: 'json',
      data: data,
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        $(target).removeAttr('disabled').html(button_text)
        if res.success == true
          $(modal).modal('hide')
          _this.model.fetch({
            data: {view: _this.current_view}
          })
          # $(_this.parent.el).find("#item-details .close-item-details .close-details").attr("data-refresh-true", true)
          # else
          # $(target).removeAttr('disabled').html(button_text)
          # _this.model.fetch({
          #   data: {view: _this.current_view}
          # })
        
      error: (err) ->
        console.log "error", err
        $(target).removeAttr('disabled').html(button_text)
    })

  refreshData: (e)->
    _this = @
    target = e.currentTarget
    if $(target).find(".modal-content").attr("data-refresh-true")
      @model.fetch({ data: {view: _this.current_view }})
      # $(_this.parent.el).find("#item-details .close-item-details .close-details").attr("data-refresh-true", true)
    # console.log "Closed Bootstrap modal"

  goBacktoPreviousPage: (e) ->
    e.preventDefault()
    if Backbone.history.history.length == 1
      params = {
        view: @current_view
      }
      FinlyF.primary_router.navigate('requests/params=' + JSON.stringify(params), {trigger: true})
    else
      Backbone.history.history.back()
    

  approveOptions: (e) ->
    e.preventDefault()

    modal = $(@el).find("#modal-approve-options")
    $(modal).html(@templateApproveOptions({item: @model.toJSON()}))
    $(modal).modal('show')



