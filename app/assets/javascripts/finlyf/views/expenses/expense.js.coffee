class FinlyF.Views.Expense extends Backbone.View
  template: HandlebarsTemplates['finlyf/expenses/expense']
  templateLoadingAnimation: HandlebarsTemplates['finlyf/base/loadingAnimation']
  templateShow: HandlebarsTemplates['finlyf/expenses/show']
  templateShowDetails: HandlebarsTemplates['finlyf/expenses/show_details']
  templatePreviewReceipt: HandlebarsTemplates['finlyf/expenses/extras/preview']
  className: 'item expense col-md-12'

  events:
    'click .select-item.expense': 'toggleSelect'
    # 'input [contenteditable=true]': 'updateModel'
    'click img.receipt-image': 'previewReceipt'
    'click .btn-edit-expense': 'edit'
    'click .btn-update-expense': 'update'
    'click .btn-delete-expense': 'delete'
    'click .btn-upload-expense-receipt': 'processUploadReceipt'
    'click .btn-confirm-upload-expense-receipt': 'uploadExpenseReceipt'
    'click .detach-uploaded-receipt': 'detachUploadedReceipt'
    'change input#edit-expense-receipt-upload': 'showUploadedReceipt'

  initialize: (options) ->
    # console.log "Options", options
    _this = @
    @preview = options.preview
    if options
      @current_view = options.view
    if options.parent
      @parent = options.parent

    if @preview
      @screen = options.screen #from which screen it is being viewed
      @view = options.view


      $(@el).removeClass("item")
      @model = new FinlyF.Models.Expense({id: options.model_id})
      @model.fetch({
        data: {
          view: _this.view
          authenticity_token: $("#authenticity_token").val()
        }
      })






    # #is being previewed from a report
    # if options.report
    #   @report_preview = options.report
    # # if options.report
    # #   @preview_in_report = true
    # if options.parent
    #   @parent = options.parent
    # if @preview
    #   @view = options.view
      # @view = @parent.params.view || options.view
      # console.log "Preview is passed true and view is", @view, @parent
      # $(@el).removeClass("item")
      # @model = new FinlyF.Models.Expense({id: options.model_id})
      # @model.fetch({
      #   data: {
      #     view: _this.view
      #     authenticity_token: $("#authenticity_token").val()
      #   }
      # })
    @model.on('sync', @populateDetails, @)
    @model.on('change', @showSaveOption, @)

  render: ->
    unless @preview
      $(@el).addClass('no-padding')
      @model.set('view', @current_view)
      $(@el).html(@template({ item: @model.toJSON() }))
    else
      $(@el).html(@templateShow())
      $(@el).find("#item-show-details").html(@templateLoadingAnimation())
    @

  toggleSelect: (e) ->
    if $(e.currentTarget).prop('checked')
      $(@el).addClass('selected')
    else
      $(@el).removeClass('selected')

    @parent.trigger('item:selected')

  previewReceipt: (e) ->
    console.log "Will preview receipt"
    modal = $("#modal-receipt-preview")
    console.log modal
    $(modal).html(@templatePreviewReceipt({item: @model.toJSON()}))
    $(modal).modal('show')

  populateDetails: ->
    @model.set('view', @view)
    if @report_preview
      # @model.set('report_preview', true)
      # @model.set('view', @view)
      @model.set('screen', @screen)
    $(@el).find("#item-show-details").html(@templateShowDetails({item: @model.toJSON()}))

  showSaveOption: ->
    $(".btn-update-item").css("display", "inline");

  delete: ->
    _this = @
    @model.destroy({
      data: {
        'authenticity_token': $("#authenticity_token").val()
      },
      processData: true,
      success: (model, res) ->
        FinlyF.snapNotify(res.messages)
        # console.log "suc", res
        $(_this.parent.el).find("#item-details .close-item-details button.close-details").attr("data-refresh-true", true)
        _this.parent.trigger('item:destroyed')
      error: (err) ->
        console.log "Error", err
    })

  edit: (e) ->
    _this = @
    $(e.currentTarget).html("<i class='fa fa-check-circle'></i>&nbsp;&nbsp;Update").removeClass('btn-edit-expense btn-warning').addClass('btn-update-expense btn-success')
    $(@el).find(".item-attr-preview").css("display", "none")
    $(@el).find(".item-attr-edit").css("display", "block")

    category_select = $("#modal-new .modal-body").find(".newExpenseCategory")
    category_select = $(@el).find(".editExpenseCategory")

    FinlyF.appendCategoriesTo(category_select).done(->
      $(category_select).val(_this.model.get('category_id'))
      )
    # options = $("#newExpenseCategory option")
    # for option in options
    #   $('<option/>', {
    #     value: $(option).attr('value')
    #     text: $(option).text()
    #   }).appendTo(category_select)

    $(@el).find(".datepicker").datepicker({
      dateFormat: "dd-mm-yy"
    })


  detachUploadedReceipt: (e) ->
    e.preventDefault()
    $(e.currentTarget).addClass('hidden')
    # console.log "Will remove the receipt!"
    # /assets/images/receipt-placeholder.png

    target = $(e.currentTarget).closest('.item-receipt')
    # close_button = $(target).find('.remove-uploaded-receipt')
    input = $(target).find('input[type=file]#edit-expense-receipt-upload')
    image = $(target).find("img#edit-preview-image")

    $(image).attr('src', '/assets/images/receipt-placeholder.png')
    # input.replaceWith(input.val(null).clone(true))
    input2 = input.after(input.clone())
    $(input2).attr('type', 'text').attr('name', "expense[receipts_attributes]").attr('id', 'edit-expense-receipt-upload-text').val(null)
    # $(input).attr('type', 'text').val(null)
    $(target).find('.btn-attach-existing-receipts').removeClass('hidden')

  showUploadedReceipt: (e) ->
    # console.log "hello from jkljfklasd"
    # onchange="document.getElementById('edit-preview-image').src = window.URL.createObjectURL(this.files[0])"
    file = e.currentTarget

    target = $(e.currentTarget).closest('.item-receipt')
    # input = $(target).find('input[type=file]#expense-receipt-upload')
    close_button = $(target).find('.detach-uploaded-receipt')
    image = $(target).find("img#edit-preview-image")
    image_url = window.URL.createObjectURL(file.files[0])
    $(image).attr('src', image_url)
    $(close_button).removeClass('hidden')
    $(target).find("#edit-expense-receipt-upload-text").remove()

    $(target).find('.btn-attach-existing-receipts').addClass('hidden')
    # $(e.currentTarget)window.URL.createObjectURL(this.files[0])

  processUploadReceipt: (e) ->
    target = e.currentTarget
    $(target).addClass('btn-confirm-upload-expense-receipt btn-success').removeClass('btn-upload-expense-receipt btn-warning').html("<i class='fa fa-upload'></i>&nbsp;&nbsp;Upload Receipt")

    receipt_div = $(@el).find('.receipt-area')

    $(receipt_div).find(".item-attr-preview").css("display", "none")
    $(receipt_div).find(".item-attr-edit").css("display", "block")

  uploadExpenseReceipt: (e) ->
    target = e.currentTarget
    $(target).html("&nbsp;&nbsp;&nbsp;&nbsp;<i class='fa fa-spin fa-circle-o-notch'></i>&nbsp;&nbsp;&nbsp;&nbsp;").attr('disabled', true)

    _this = @
    e.preventDefault()
    formData = new FormData($(@el).find('form#form-update-item')[0])

    $.ajax({
      url: '/expenses/' + _this.model.get('id')
      type: "PUT",
      data: formData,
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          if $(target).closest('.modal-content')
            #Adding refresh trigger in reprots#show
            $(target).closest('.modal-content').attr('data-refresh-true', true)

            #Adding refresh trigger in expense#index
            if _this.parent
              $(_this.parent.el).find("#item-details .close-item-details button.close-details").attr("data-refresh-true", true)
          _this.model.fetch({
            data: {
              view: _this.view
            }
          })
          # if _this.report_preview
          # $("#modal-new").modal('hide')
          # _this.refetchCollection()
        else
          $(target).html("<i class='fa fa-upload'></i>&nbsp;&nbsp;Upload Receipt")
          $(target).attr('disabled', false)

      error: (err) ->
        $(target).html("<i class='fa fa-upload'></i>&nbsp;&nbsp;Upload Receipt")
        $(target).attr('disabled', false)
      cache: false,
      contentType: false,
      processData: false
    })




  update: (e) ->
    target = e.currentTarget
    $(target).html("&nbsp;&nbsp;&nbsp;&nbsp;<i class='fa fa-spin fa-circle-o-notch'></i>&nbsp;&nbsp;&nbsp;&nbsp;").removeClass('btn-update-expense')
    $(target).attr('disabled', true)      

    _this = @
    e.preventDefault()
    formData = new FormData($(@el).find('form#form-update-item')[0])

    $.ajax({
      url: '/expenses/' + _this.model.get('id')
      type: "PUT",
      data: formData,
      success: (res) ->
        FinlyF.snapNotify(res.messages)
        if res.success == true
          if $(target).closest('.modal-content')
            #Adding refresh trigger in reprots#show
            $(target).closest('.modal-content').attr('data-refresh-true', true)

            #Adding refresh trigger in expense#index
            if _this.parent
              $(_this.parent.el).find("#item-details .close-item-details button.close-details").attr("data-refresh-true", true)
          _this.model.fetch({
            data: {
              view: _this.view
            }
          })
          # if _this.report_preview
          # $("#modal-new").modal('hide')
          # _this.refetchCollection()
        else
          $(target).html("<i class='fa fa-check-circle'></i>&nbsp;&nbsp;Update").addClass('btn-update-expense')
          $(target).attr('disabled', false)

      error: (err) ->
        $(target).html("<i class='fa fa-check-circle'></i>&nbsp;&nbsp;Update").addClass('btn-update-expense')
        console.log "Error", err 
        $(target).attr('disabled', false)
      cache: false,
      contentType: false,
      processData: false
    })



    values = {}

    # if(event){ event.preventDefault(); }

    # _.each($(@el).find('form#form-update-item').serializeArray(), (input) ->
    #   values[ input.name ] = input.value
    # )
    # values.authenticity_token = $("#authenticity_token").val()
    # model = new FinlyF.Models.Expense({
    #   id: @model.get('id')
    # })
    # console.log "Putting data", values, model.toJSON()
    # response = model.save(values, {
      
    #   iframe: true,
    #   files: this.$('form :file'),
    #   data: values,
    #   patch: true,
    #   put: true,
    #   processData: true
    #   success: (model, res) ->
    #     FinlyF.snapNotify(res.messages)
    #     #Refresh expense index if data changed. Refresh is done - expense_index.js.coffee.closeDetails
    #     $("#item-details .close-item-details button.close-details").attr("data-refresh-true", true)

    #     #Refresh report if data changed, refresh is done in - report.js.coffee.refreshData
    #     if $(target).closest("#modal-mp")
    #       $(target).closest("#modal-mp").find(".modal-content").attr("data-refresh", true)
    #     _this.model.fetch()
    #     # console.log "Success"
    #     # console.log model, res
    #     # if res.status == "success"
    #     #   $("#modal-new").modal('hide')
    #     #   _this.refetchCollection()
    #   error: (err) ->
    #     console.log "Error", err

    # })
    


#Features
# 1. Compare models if anything has changed. Or else hide the show button.