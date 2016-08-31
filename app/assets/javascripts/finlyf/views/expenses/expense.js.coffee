class FinlyF.Views.Expense extends Backbone.View
  template: HandlebarsTemplates['finlyf/expenses/expense']
  templateShow: HandlebarsTemplates['finlyf/expenses/show']
  templateShowDetails: HandlebarsTemplates['finlyf/expenses/show_details']
  className: 'item col-md-12'

  events:
    'click .select-item': 'toggleSelect'
    # 'input [contenteditable=true]': 'updateModel'
    'click .btn-edit-item': 'edit'
    'click .btn-update-item': 'update'
    'click .btn-delete-item': 'delete'

  initialize: (options) ->
    _this = @
    @preview = options.preview
    if options.parent
      @parent = options.parent
    if @preview
      # console.log "Preview is passed true"
      $(@el).removeClass("item")
      @model.fetch()
    @model.on('sync', @populateDetails, @)
    @model.on('change', @showSaveOption, @)

  render: ->
    unless @preview
      $(@el).html(@template({ item: @model.toJSON() }))
    else
      $(@el).html(@templateShow())
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

    @parent.trigger('item:selected')

  populateDetails: ->
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
        _this.parent.trigger('item:destroyed')
      error: (err) ->
        console.log "Error", err
    })

  edit: (e) ->
    $(e.currentTarget).html("<i class='fa fa-check-circle'></i>&nbsp;&nbsp;Update").removeClass('btn-edit-item').addClass('btn-update-item')
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

  update: (e) ->
    $(e.currentTarget).html("<i class='fa fa-edit'></i>&nbsp;&nbsp;Edit").removeClass('btn-update-item').addClass('btn-edit-item')

    _this = @
    values = {}

    # if(event){ event.preventDefault(); }

    _.each($(@el).find('form#form-update-item').serializeArray(), (input) ->
      values[ input.name ] = input.value
    )
    values.authenticity_token = $("#authenticity_token").val()
    model = new FinlyF.Models.Expense({
      id: @model.get('id')
    })
    # # console.log("Putting data")
    response = model.save(values, {
      patch: true,
      iframe: true,
      files: this.$('form :file'),
      data: values,
      processData: true
      success: (model, res) ->
        $("#item-details .close-item-details button.close-details").attr("data-refresh-true", true)
        # console.log "Success"
        # console.log model, res
        # if res.status == "success"
        #   $("#modal-new").modal('hide')
        #   _this.refetchCollection()
      error: (err) ->
        console.log "Error", err

    })
    


#Features
# 1. Compare models if anything has changed. Or else hide the show button.