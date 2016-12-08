class FinlyF.Views.Report extends Backbone.View

  templateSkeleton: HandlebarsTemplates['finlyf/reports/base/reportShowSkeleton']
  templateShowNavbar: HandlebarsTemplates['finlyf/reports/navbar/show/navbar']


  template: HandlebarsTemplates['finlyf/reports/crud/report']
  templateLoadingAnimation: HandlebarsTemplates['finlyf/base/loadingAnimation']
  # templateShow: HandlebarsTemplates['finlyf/reports/crud/show']
  templateShowDetails: HandlebarsTemplates['finlyf/reports/crud/show']

  templateNewExpense: HandlebarsTemplates['finlyf/expenses/new']
  templateShowExpense: HandlebarsTemplates['finlyf/reports/expenses/show']
  templateExistingExpense: HandlebarsTemplates['finlyf/reports/expenses/existingExpenses']
  templateReceiptPreview: HandlebarsTemplates['finlyf/reports/extras/previewReceipt']
  className: 'item col-sm-12 report'

  events:
    'click .select-item': 'toggleSelect'
    'input [contenteditable=true]': 'updateModel'
    'click .btn-update-item': 'update'
    'click .add-new-expense': 'newExpense'
    'click .remove-uploaded-receipt': 'removeUploadedReceipt'
    'change input#expense-receipt-upload': 'showUploadedReceipt'

    'click .add-existing-expense': 'existingExpense'
    'click .btn-create-expense': 'createExpense'
    'click .btn-post-comment': 'postComment'

    'click .receipt': 'previewReceipt'

    'click .btn-delete-item': 'delete'
    'click .btn-edit-item': 'edit'
    'click .btn-update-item': 'update'
    # 'click .btn-submit-item': 'submit'
    # 'click .btn-retract-item': 'retract'

    'click .btn-delete-sub-item': 'deleteSub'
    'click .btn-view-sub-item': 'viewSub'
    'click .btn-reject-sub-item': 'rejectSub'
    'hidden.bs.modal #modal-mp': 'refreshData'
    'keypress .comment-content': 'postCommentByEnter'


    #reports
    'click .btn-report-action': 'reportAction'
    'click .confirm-add-existing-expense': 'addExistingExpenses'

    'click .btn-go-back': 'goBacktoPreviousPage'

  initialize: (options) ->
    # console.log "we're here in report show", options
    # @parent = options.parent
    _this = @
    data = {}
    
    if options
      @params = options.params
      @preview = options.preview
    if @preview
      $(@el).removeClass("item col-sm-12 report")
      @current_view = options.params.view ##NEED TO ADD THIS IN REPORTS
      if @current_view
        data.view = @current_view
      if @params.ref
        data.ref = @params.ref
      $(@el).removeClass("item").addClass("bg-white")
      @model = new FinlyF.Models.Report({id: options.model_id})
      @model.fetch({data: data})
    @model.on('sync', @populateDetails, @)
    @model.on('change', @showSaveOption, @)
    @on('expense:selected', @showExpenseSelectOption, @)#REF==3I
    

  render: ->
    unless @preview
      $(@el).html(@template({ item: @model.toJSON() }))
    else
      $(@el).html(@templateSkeleton())
      # $(@el).find(".main").html(@templateShow())
      # $(@el).find("#item-show-details").html(@templateLoadingAnimation())
      FinlyF.structureActions(@el, @params)
    @

  updateModel: (e) ->
    # _this = @
    field = $(e.target).attr('data-field')
    value = e.target.innerText
    @model.set(field, value);

  # update: ->
  #   console.log "Hi"
  #   return
  #   @model.save({hi: "hello"}, {patch: true})

  toggleSelect: (e) ->
    if $(e.currentTarget).prop('checked')
      $(@el).addClass('selected')
    else
      $(@el).removeClass('selected')
    @parent.trigger('item:selected')

  populateDetails: ->
    @model.set('current_view', @current_view)
    $(@el).find(".navbar-full").html(@templateShowNavbar({item: @model.toJSON()}))
    # $(@el).find("#item-show-details").html(@templateShowDetails({item: @model.toJSON()}))
    $(@el).find(".main").html(@templateShowDetails({item: @model.toJSON()}))


    # $(@el).find(".show-detail-title").css("height", "49");
    # $(@el).find(".show-detail-title").css("height", "50");

  showSaveOption: ->
    $(".btn-update-item").css("display", "inline");

  newExpense: (e) ->
    _this = @
    data = {
      report_id: $(e.currentTarget).attr('data-item-id')
    }
    $("#modal-new").attr("data-backdrop", true)
    $("#modal-new .modal-body").html(@templateNewExpense({data: data}))
    $("#modal-new .modal-body").find("[name=authenticity_token]").val($("#authenticity_token").val())

    #Populate categories from index.json.jbuilder  
    category_select = $("#modal-new .modal-body").find(".newExpenseCategory")
    options = $("#newExpenseCategory option")
    for option in options
      $('<option/>', {
        value: $(option).attr('value')
        text: $(option).text()
      }).appendTo(category_select) 
    
    $("#modal-new .modal-dialog").css("width", "60%") 
    $("#modal-new").modal('show')
    $("#modal-new").find(".datepicker").datepicker({dateFormat: "yy-mm-dd"})
    # $("#modal-new").find('.btn-create-expense').on('click', (e) ->
    #   _this.createExpense(@);
    # )

    # Since the modal is outside the scope of this view, events need to be manually attached
    modal_new = $("#modal-new")
    $(modal_new).find(".remove-uploaded-receipt").on('click', (e) ->
      _this.removeUploadedReceipt(e)
    )
    $(modal_new).find("input#expense-receipt-upload").on('change', (e) ->
      _this.showUploadedReceipt(e)
    )


  # New expense
  showUploadedReceipt: (e) ->
    console.log "Hello", e
    file = e.currentTarget

    target = $(e.currentTarget).closest('.upload-receipt')
    # input = $(target).find('input[type=file]#expense-receipt-upload')
    close_button = $(target).find('.remove-uploaded-receipt')
    image = $(target).find("img#preview-image")
    image_url = window.URL.createObjectURL(file.files[0])
    $(image).attr('src', image_url)
    $(close_button).removeClass('hidden')
    # $(e.currentTarget)window.URL.createObjectURL(this.files[0])

  # New expense
  removeUploadedReceipt: (e) ->
    e.preventDefault()
    $(e.currentTarget).addClass('hidden')
    console.log "Will remove the receipt!"
    # /assets/images/receipt-placeholder.png

    target = $(e.currentTarget).closest('.upload-receipt')
    # close_button = $(target).find('.remove-uploaded-receipt')
    input = $(target).find('input[type=file]#expense-receipt-upload')
    image = $(target).find("img#preview-image")

    $(image).attr('src', '/assets/images/receipt-placeholder.png')
    input.replaceWith(input.val('').clone(true))

    # $(close_button).css('display', 'none')

  createExpense: (e) ->
    console.log "Creating expense"
    # if e
    #   console.log "event", e
    #   e.preventDefault()

    # console.log "E is", e

    # e.preventDefault()
    # target = e.currentTarget

    $(e).html("&nbsp;&nbsp;&nbsp;<i class='fa fa-spin fa-circle-o-notch'></i>&nbsp;&nbsp;&nbsp;")
    $(e).attr('disabled', 'disabled')
    
    _this = @
    formData = new FormData($('#modal-new form#new-item')[0])
    $.ajax({
      url: '/expenses'
      type: "POST",
      data: formData,
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
          $(e).html("Create")
          $(e).attr('disabled', false) 
      error: (err) ->
        console.log "Error", err 
        $(e).html("Create")
        $(e).attr('disabled', false)
      cache: false,
      contentType: false,
      processData: false
    })


  existingExpense: (e) ->
    report_id = $(e.currentTarget).attr('data-item-id')
    expense_view = new FinlyF.Views.ExpensesIndex({
      indexOnly: true
      # parent: @
    })
    $(@el).find("#modal-mp").html(@templateExistingExpense())
    $(@el).find("#modal-mp .modal-content .modal-body").html(expense_view.render().el)
    $(@el).find("#modal-mp").modal('show')
    $(@el).find("#modal-mp .datepicker").datepicker({dateFormat: "yy-mm-dd"})

  showExpenseSelectOption: ->
    # console.log "Here we are"

    modal_header = $(@el).find("#modal-mp .modal-content .modal-header")
    container = $(@el).find("#modal-mp .modal-content .modal-body")
    items = $(container).find("#items .item")

    flag = false
    for item in items
      if $(item).find('.select-item').prop('checked')
        flag = true
    if flag == true
      $(modal_header).find('.confirm-add-existing-expense').css("display", 'inline')
    else
      $(modal_header).find('.confirm-add-existing-expense').css("display", 'none')

  addExistingExpenses: (e) ->
    _this = @
    modal = $(@el).find("#modal-mp")
    modal_header = $(modal).find(".modal-content .modal-header")
    container = $(modal).find(".modal-content .modal-body")
    items = $(container).find("#items .item")

    expense_ids = []
    flag = false
    for item in items
      selected_item = $(item).find('.select-item')
      if $(selected_item).prop('checked')
        expense_ids.push($(selected_item).attr('data-item-id'))

    # console.log expenses

    $.ajax({
      url: _this.model.urlRoot + "/" + _this.model.get('id') + "/add_expenses",
      type: 'POST',
      dataType: 'json',
      data: {
        authenticity_token: $("#authenticity_token").val()
        expense_ids: expense_ids
      },
      success: (res)->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          $(modal).modal('hide')
          $(modal).html("")
          _this.model.fetch({ data: {view: _this.current_view}})
          # $(_this.parent.el).find("#item-details .close-item-details .close-details").attr("data-refresh-true", true)
      error: (err) ->
        console.log "Error", err
    })


  edit: (e) ->
    #Warning!!! Dirty codes ahead!
    $(e.currentTarget).addClass('btn-update-item btn-success').removeClass('btn-edit-item btn-warning').html("Update  <i class='fa fa-check'></i>")

    _this = @
    # $(@el).find(".item-name").html("<input type='text' class='item-name-edit' />")
    # $(@el).find(".item-name .item-name-edit").val(_this.model.get('name'))

    target_select = $(@el).find(".item-policy-edit")
    $(target_select).val($(target_select).attr('data-default-value'))

    $(@el).find('.item-attr-edit').css("display", "inline")
    $(@el).find('.item-attr-preview').css('display', 'none')
    # select = $('<select />', {
    #   name: 'item-policy',
    #   class: 'item-policy-edit',

    # })

    # policies = $(@model.get('policies'))
    # for policy in policies
    #   console.log policy
    #   $('<option />', {
    #     text: policy.name,
    #     value: policy.id
    #   }).appendTo(select)

    # $(target_select).html(select)

  update: (e) ->
    e.preventDefault()
    _this = @
    target = e.currentTarget
    $(target).html("<i class='fa fa-circle-o-notch fa-spin'></i>").attr('disabled', true)

    policy_id = $(@el).find('select.item-policy-edit').val()
    name = $(@el).find('input.item-name-edit').val()
    memo = $(@el).find('textarea.item-memo-edit').val()
    
    data = {
      name: name,
      policy_id: policy_id,
      memo: memo
    }
    model = new FinlyF.Models.Report({id: @model.get('id')})
    model.save(data, {
      success: (model, res) ->
        FinlyF.snapNotify(res.messages)
        _this.model.fetch()
      error: (err) ->
        FinlyF.snapNotify(err.messages)
        console.log "Err", err
    })
    # @model.save({report: {name: name}}, {
    #   success: (model, res) ->
    #     console.log model, res
    #   error: (err) ->
    #     console.log "Error", err
    # })

    ##Below code is not needed, as the model sync will reload the view!
    # $(@el).find(".item-name").html(@model.get('name'))
    # $(@el).find(".item-policy").html(@model.get('policy') || "None")
    # $(@el).find(".item-name .item-name-edit").val(_this.model.get('name'))
    # $(e.currentTarget).addClass('btn-edit-item btn-warning').removeClass('btn-update-item btn-success').html("Edit  <i class='fa fa-edit'></i>")

  postComment: (e) ->
    $(e.currentTarget).text('Posting...').attr('disabled', true)
    _this = @
    target = $(e.currentTarget)
    report_id = $(target).attr('data-item-id')
    data = {
      comment: $(target).closest('.form-new-comment').find('.comment-content').val()
    }

    # @model.set('comment', comment)
    model = new FinlyF.Models.Report(data)
    model.urlRoot = '/reports/' + report_id + '/comment'
    # console.log _this.parent.params.view
    model.save({view: _this.params.view}, {
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

  postCommentByEnter: (e) ->
    if e.keyCode == 13
      $(e.currentTarget).closest('.form-new-comment').find('.btn-post-comment').click()
      return false


  delete: (e) ->
    _this = @
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
        FinlyF.snapNotify(res.messages)
        FinlyF.primary_router.navigate('reports/params=' + JSON.stringify(params), {trigger: true})
        # console.log res
        # _this.parent.trigger('item:destroyed')
      error: (err) ->
        console.log "Error", err

    })

  reportAction: (e) ->
    _this = @
    url = $(e.currentTarget).attr('data-url')
    $.ajax({
      url: url,
      type: 'patch',
      dataType: 'json',
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          _this.model.fetch({
            data: {view: _this.current_view}
          })
          # $(_this.parent.el).find("#item-details .close-item-details .close-details").attr("data-refresh-true", true)
        else
          _this.model.fetch({
            data: {view: _this.current_view}
          })
      error: (err) ->
        console.log "error", err
    })

  refreshData: (e)->
    _this = @
    target = e.currentTarget
    if $(target).find(".modal-content").attr("data-refresh-true")
      @model.fetch({ data: {view: _this.current_view }})
      # $(_this.parent.el).find("#item-details .close-item-details .close-details").attr("data-refresh-true", true)
    # console.log "Closed Bootstrap modal"

  deleteSub: (e) ->
    # console.log "deleteing sub"
    _this = @
    expense_id = $(e.currentTarget).attr('data-item-id')
    $.ajax({
      url: _this.model.urlRoot + "/" + _this.model.get('id') + "/remove_expenses?expense_id=" + expense_id,
      type: 'DELETE',
      dataType: 'json',
      data: {
        authenticity_token: $("#authenticity_token").val()
      },
      success: (res)->
        FinlyF.snapNotify(res.messages)
        _this.model.fetch({ data: {view: _this.current_view}})
        # $(_this.parent.el).find("#item-details .close-item-details .close-details").attr("data-refresh-true", true)
      error: (err) ->
        console.log "Error", err
    })

  viewSub: (e)->
    # console.log "view", @current_view
    target = e.currentTarget
    expense_id = $(target).attr('data-item-id')

    # model = new FinlyF.Models.Expense({id: expense_id})

    preview_view = new FinlyF.Views.Expense({
      model_id: expense_id
      preview: true
      view: @current_view
      report: true #will be removed
      screen: 'report'
      # parent: @
    })
    $(@el).find("#modal-mp").html(@templateShowExpense())
    $(@el).find("#modal-mp .modal-content .modal-body .row").html(preview_view.render().el)
    $(@el).find("#modal-mp").modal('show')
    $("#modal-mp").find(".datepicker").datepicker({dateFormat: "yy-mm-dd"})


  rejectSub: (e) ->
    _this = @
    target = e.currentTarget
    expense_id = $(target).attr('data-item-id')
    # console.log "Expense_id", expense_id
    $.ajax({
      url: '/reports/' + _this.model.get('id') + '/reject_expense'
      method: 'PATCH'
      dataType: 'JSON'
      data: {
        expense_id: expense_id
        view: _this.current_view
      },
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          _this.model.fetch({
            data: {
              view: _this.current_view
            }
        })
      error: (err) ->
        console.log err
    })

    # model = new FinlyF.Models.Expense({id: expense_id})

    # preview_view = new FinlyF.Views.Expense({
    #   model: model
    #   preview: true
    # })
    # $(@el).find("#modal-mp .modal-content").html(@templateExistingExpense())
    # $(@el).find("#modal-mp .modal-content .modal-body").html(preview_view.render().el)
    # $(@el).find("#modal-mp").modal('show')

  submit: (e) ->
    _this = @
    report_id = @model.get('id')

    $.ajax({
      url: "/reports/" + report_id + "/submit",
      dataType: 'json',
      data: {
        report_id: report_id,
        authenticity_token: $("#authenticity_token").val()
      },
      type: 'PATCH',
      success: (res) ->
        FinlyF.snapNotify(messages)
        # console.log res
        _this.model.fetch({
          data: {
            view: _this.current_view
          }
        })
      error: (err) ->
        console.log err
    })

  retract: (e) ->
    e.preventDefault()
    _this = @
    report_id = @model.get('id')

    $.ajax({
      url: "/reports/" + report_id + "/retract",
      dataType: 'json',
      data: {
        report_id: report_id,
        authenticity_token: $("#authenticity_token").val()
      },
      type: 'PATCH',
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        # console.log res
        _this.model.fetch({
          data: {
            view: _this.current_view
          }
        })
      error: (err) ->
        console.log err
    })

  previewReceipt: (e) ->
    target = e.currentTarget

    image_url = $(target).find("img").attr('src')

    item = {
      url: image_url
    }

    $("#modal-receipt-preview").html(@templateReceiptPreview({item: item}))
    $("#modal-receipt-preview").modal('show')


  goBacktoPreviousPage: (e) ->
    e.preventDefault()
    Backbone.history.history.back()
