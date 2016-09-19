class FinlyF.Views.Expense extends Backbone.View
  template: HandlebarsTemplates['finlyf/expenses/expense']
  templateShow: HandlebarsTemplates['finlyf/expenses/show']
  templateShowDetails: HandlebarsTemplates['finlyf/expenses/show_details']
  className: 'item col-md-12'

  events:
    'click .select-item': 'toggleSelect'
    # 'input [contenteditable=true]': 'updateModel'
    'click .btn-edit-expense': 'edit'
    'click .btn-update-expense': 'update'
    'click .btn-delete-expense': 'delete'

  initialize: (options) ->
    _this = @
    @preview = options.preview

    #is being previewed from a report
    if options.report
      @report_preview = options.report
    # if options.report
    #   @preview_in_report = true
    if options.parent
      @parent = options.parent
    if @preview
      @view = options.view
      # console.log "Preview is passed true"
      $(@el).removeClass("item")
      @model = new FinlyF.Models.Expense({id: options.model_id})
      @model.fetch({
        data: {
          view: _this.view
          authenticity_token: $("#authenticity_token").val()
        }
      })
    @model.on('sync', @populateDetails, @)
    @model.on('change', @showSaveOption, @)

  render: ->
    unless @preview
      $(@el).html(@template({ item: @model.toJSON() }))
    else
      $(@el).html(@templateShow())
    @

  toggleSelect: (e) ->
    if $(e.currentTarget).prop('checked')
      $(@el).addClass('selected')
    else
      $(@el).removeClass('selected')

    @parent.trigger('item:selected')

  populateDetails: ->
    if @report_preview
      @model.set('report_preview', true)
      @model.set('view', @view)
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
    $(e.currentTarget).html("<i class='fa fa-check-circle'></i>&nbsp;&nbsp;Update").removeClass('btn-edit-expense').addClass('btn-update-expense')
    $(@el).find(".item-attr-preview").css("display", "none")
    $(@el).find(".item-attr-edit").css("display", "block")

    category_select = $("#modal-new .modal-body").find(".newExpenseCategory")
    category_select = $(@el).find(".editExpenseCategory")
    options = $("#newExpenseCategory option")
    for option in options
      $('<option/>', {
        value: $(option).attr('value')
        text: $(option).text()
      }).appendTo(category_select)

    $(category_select).val(@model.get('category_id'))
    $(@el).find(".datepicker").datepicker({
      dateFormat: "yy-mm-dd"
    })


  update: (e) ->
    target = e.currentTarget

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
          _this.model.fetch()
          # if _this.report_preview
          # $("#modal-new").modal('hide')
          # _this.refetchCollection()
        # else
          # $(target).html("<i class='fa fa-edit'></i>&nbsp;&nbsp;Edit").removeClass('btn-update-expense').addClass('btn-edit-expense')

      error: (err) ->
        console.log "Error", err 
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