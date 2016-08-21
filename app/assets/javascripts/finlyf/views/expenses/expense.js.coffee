class FinlyF.Views.Expense extends Backbone.View
  template: HandlebarsTemplates['finlyf/expenses/expense']
  templateShow: HandlebarsTemplates['finlyf/expenses/show']
  templateShowDetails: HandlebarsTemplates['finlyf/expenses/show_details']
  className: 'expense col-md-12'

  events:
    'click .select-item': 'toggleSelect'
    'input [contenteditable=true]': 'updateModel'
    'click .btn-update-expense': 'update'

  initialize: (options) ->
    _this = @
    @preview = options.preview
    if @preview
      # console.log "Preview is passed true"
      $(@el).removeClass("expense")
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
    $(@el).find("#item-show-details").html(@templateShowDetails({expense: @model.toJSON()}))

  showSaveOption: ->
    $(".btn-update-expense").css("display", "inline");


#Features
# 1. Compare models if anything has changed. Or else hide the show button.