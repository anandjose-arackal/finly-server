class FinlyF.Views.Expense extends Backbone.View
  template: HandlebarsTemplates['finlyf/expenses/expense']
  templateShow: HandlebarsTemplates['finlyf/expenses/show']
  templateShowDetails: HandlebarsTemplates['finlyf/expenses/show_details']
  className: 'item col-md-12'

  events:
    'click .select-item': 'toggleSelect'
    'input [contenteditable=true]': 'updateModel'
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

  update: ->
    @model.save({patch: true})

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


#Features
# 1. Compare models if anything has changed. Or else hide the show button.