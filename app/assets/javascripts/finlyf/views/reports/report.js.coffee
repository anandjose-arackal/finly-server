class FinlyF.Views.Report extends Backbone.View
  template: HandlebarsTemplates['finlyf/reports/crud/report']
  templateShow: HandlebarsTemplates['finlyf/reports/crud/show']
  templateShowDetails: HandlebarsTemplates['finlyf/reports/crud/show_details']

  templateNewExpense: HandlebarsTemplates['finlyf/expenses/new']
  templateExistingExpense: HandlebarsTemplates['finlyf/reports/expenses/existingExpenses']
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

  initialize: (options) ->
    @parent = options.parent
    _this = @
    @preview = options.preview
    if @preview
      # console.log "Preview is passed true"
      $(@el).removeClass("item").addClass("bg-white")
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

  update: ->
    @model.save({patch: true})

  toggleSelect: (e) ->
    if $(e.currentTarget).prop('checked')
      $(@el).addClass('selected')
    else
      $(@el).removeClass('selected')

  populateDetails: ->
    $(@el).find("#item-show-details").html(@templateShowDetails({item: @model.toJSON()}))

  showSaveOption: ->
    $(".btn-update-item").css("display", "inline");

  newExpense: (e) ->
    _this = @
    data = {
      report_id: $(e.currentTarget).attr('data-item-id')
    }
    $("#modal-new .modal-body").html(@templateNewExpense({data: data}))
    $("#modal-new .modal-body").find("[name=authenticity_token]").val($("#authenticity_token").val())

    #Populate categories from index.html.erb  
    category_select = $("#modal-new .modal-body").find(".newExpenseCategory")
    options = $("#newExpenseCategory option")
    for option in options
      $('<option/>', {
        value: $(option).attr('value')
        text: $(option).text()
      }).appendTo(category_select) 
    
    $("#modal-new").modal('show')
    $("#modal-new").find('.btn-create-expense').on('click', (e) ->
      _this.createExpense(@);
    )

  createExpense: (e) ->
    _this =   @
    values = {}

    # if(event){ event.preventDefault(); }

    _.each($("#modal-new form#new-item").serializeArray(), (input) ->
      values[ input.name ] = input.value
    )
    console.log values
    model = new FinlyF.Models.Expense()
    # console.log("Putting data")
    response = model.save(values, {
      iframe: true,
      files: this.$('form :file'),
      data: values
      processData: true
      success: (model, res) ->
        $("#modal-new").modal('hide')
        _this.model.fetch()
      error: (err) ->
        console.log "Error", err
    })

    console.log response

  existingExpense: (e) ->
    report_id = $(e.currentTarget).attr('data-item-id')
    $(@el).find("#modal-mp .modal-body").append(@templateExistingExpense())
    $(@el).find("#modal-mp").modal('show')

  postComment: (e) ->
    _this = @
    target = $(e.currentTarget)
    report_id = $(target).attr('data-item-id')
    data = {
      comment: $(target).closest('.form-new-comment').find('.comment-content').val()
    }

    # @model.set('comment', comment)
    model = new FinlyF.Models.Report(data)
    model.urlRoot = '/reports/' + report_id + '/comment'
    model.save(null, {
      success: (model, res) ->
        console.log model, res
        _this.model.fetch()
      error: (err) ->
        console.log "Error", err
    })
    # console.log report_id

  delete: (e) ->
    _this = @
    # @model.set('authenticity_token', $("#authenticity_token").val())
    console.log $("#authenticity_token").val()
    @model.destroy({
      data: {
        'authenticity_token': $("#authenticity_token").val()
      }
      processData: true
      success: (model, res) ->
        console.log res
        _this.parent.trigger('item:destroyed')
      error: (err) ->
        console.log "Error", err

    })

#Features
# 1. Compare models if anything has changed. Or else hide the show button.