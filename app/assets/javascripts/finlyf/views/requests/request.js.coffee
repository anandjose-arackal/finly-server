class FinlyF.Views.Request extends Backbone.View
  template: HandlebarsTemplates['finlyf/requests/crud/request']
  templateLoadingAnimation: HandlebarsTemplates['finlyf/base/loadingAnimation']
  templateShow: HandlebarsTemplates['finlyf/requests/crud/show']
  templateShowDetails: HandlebarsTemplates['finlyf/requests/crud/show_details']
  templateAddCategory: HandlebarsTemplates['finlyf/requests/crud/addRequestCategory']

  className: 'item col-sm-12'

  events:
    'click .select-item': 'toggleSelect'
    'input [contenteditable=true]': 'updateModel'
    'click .btn-update-item': 'update'
    'click .add-new-expense': 'newExpense'
    'click .add-existing-expense': 'existingExpense'
    'click .btn-create-expense': 'createExpense'
    'click .btn-post-comment': 'postComment'

    'click .btn-delete-item': 'delete'
    'click .btn-edit-item': 'edit'
    'click .btn-update-item': 'update'
    # 'click .btn-submit-item': 'submit'
    # 'click .btn-retract-item': 'retract'

    'click .btn-delete-sub-item': 'deleteSub'
    'click .btn-view-sub-item': 'viewSub'
    'click .btn-reject-sub-item': 'rejectSub'
    'hidden.bs.modal #modal-mp': 'refreshData'
    'click .btn-add-request-category': 'addRequestCategory'
    'click .btn-remove-request-category': 'removeRequestCategory'

    #reports
    'click .btn-report-action': 'reportAction'
    'click .confirm-add-existing-expense': 'addExistingExpenses'

  initialize: (options) ->
    console.log "here in requests"
    @parent = options.parent
    _this = @
    @preview = options.preview
    data = {}
    if @preview
      @current_view = options.current_view ##NEED TO ADD THIS IN REPORTS
      if @current_view
        data.view = @current_view
      $(@el).removeClass("item").addClass("bg-white")
      @model = new FinlyF.Models.Request({id: options.model_id})
      @model.fetch({data: data})
    @model.on('sync', @populateDetails, @)
    @model.on('change', @showSaveOption, @)
    @on('expense:selected', @showExpenseSelectOption, @)#REF==3I
    

  render: ->
    unless @preview
      $(@el).html(@template({ item: @model.toJSON() }))
    else
      $(@el).html(@templateShow())
      $(@el).find("#item-show-details").html(@templateLoadingAnimation())
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
    $(@el).find("#item-show-details").html(@templateShowDetails({item: @model.toJSON()}))
    $(@el).find("#item-show-details .datepicker").datepicker({ dateFormat: "yy-mm-dd" })

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
    $.ajax({
      url: '/money_request/' + _this.model.get('id')
      type: "PUT",
      data: formData,
      success: (res) ->
        # console.log res.messages
        FinlyF.snapNotify(res.messages)
        if res.success == true
          $(_this.parent.el).find("#item-details .close-item-details .close-details").attr("data-refresh-true", true)
          $("#modal-new").modal('hide')
          _this.model.fetch({
            data: {
              view: _this.current_view
            }
          })
      error: (err) ->
        console.log "Error", err 
      cache: false,
      contentType: false,
      processData: false
    })

  postComment: (e) ->
    e.preventDefault()
    $(e.currentTarget).text('Posting...')
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
    model.save({view: _this.parent.params.view}, {
      success: (model, res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          _this.model.fetch({
            data: {
              view: _this.current_view
            }
          })
        else
          $(e.currentTarget).text('Post')
      error: (err) ->
        console.log "Error", err
        $(e.currentTarget).text('Post')
    })
    # console.log report_id

  delete: (e) ->
    e.preventDefault()
    _this = @
    # @model.set('authenticity_token', $("#authenticity_token").val())
    # console.log $("#authenticity_token").val()
    @model.destroy({
      data: {
        'authenticity_token': $("#authenticity_token").val()
      }
      processData: true
      success: (model, res) ->
        FinlyF.snapNotify(res.messages)
        # console.log res
        _this.parent.trigger('item:destroyed')
      error: (err) ->
        console.log "Error", err

    })

  reportAction: (e) ->
    # console.log "hi"
    e.preventDefault()
    _this = @
    url = $(e.currentTarget).attr('data-url')
    $.ajax({
      url: url,
      type: 'PATCH',
      dataType: 'json',
      data: {
        type: $(e.currentTarget).attr('data-action-type')
      }
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          _this.model.fetch({
            data: {view: _this.current_view}
          })
          $(_this.parent.el).find("#item-details .close-item-details .close-details").attr("data-refresh-true", true)
          
      error: (err) ->
        console.log "Error", err
    })

  refreshData: (e)->
    _this = @
    target = e.currentTarget
    if $(target).find(".modal-content").attr("data-refresh-true")
      @model.fetch({ data: {view: _this.current_view }})
      $(_this.parent.el).find("#item-details .close-item-details .close-details").attr("data-refresh-true", true)
    # console.log "Closed Bootstrap modal"


  # submit: (e) ->
  #   e.preventDefault()
  #   _this = @
  #   request_id = @model.get('id')

  #   $.ajax({
  #     url: "/money_request/" + request_id + "/submit",
  #     dataType: 'json',
  #     data: {
  #       money_request_id: money_request_id,
  #       authenticity_token: $("#authenticity_token").val()
  #       type: 'submit'
  #     },
  #     type: 'PATCH',
  #     success: (res) ->
  #       FinlyF.snapNotify(messages)
  #       # console.log res
  #       _this.model.fetch({
  #         data: {
  #           view: _this.current_view
  #         }
  #       })
  #     error: (err) ->
  #       console.log err
  #   })

  # retract: (e) ->
  #   e.preventDefault()
  #   _this = @
  #   report_id = @model.get('id')

  #   $.ajax({
  #     url: "/money_request/" + report_id + "/retract",
  #     dataType: 'json',
  #     data: {
  #       report_id: report_id,
  #       authenticity_token: $("#authenticity_token").val()
  #     },
  #     type: 'PATCH',
  #     success: (res) ->
  #       FinlyF.snapNotify(res.messages)
  #       # console.log res
  #       _this.model.fetch({
  #         data: {
  #           view: _this.current_view
  #         }
  #       })
  #     error: (err) ->
  #       console.log err
  #   })




