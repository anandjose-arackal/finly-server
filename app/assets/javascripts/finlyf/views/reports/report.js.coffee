class FinlyF.Views.Report extends Backbone.View
  template: HandlebarsTemplates['finlyf/reports/crud/report']
  templateShow: HandlebarsTemplates['finlyf/reports/crud/show']
  templateShowDetails: HandlebarsTemplates['finlyf/reports/crud/show_details']
  className: 'item col-md-12'

  events:
    'click .select-item': 'toggleSelect'
    'input [contenteditable=true]': 'updateModel'
    'click .btn-update-item': 'update'

  initialize: (options) ->
    _this = @
    @preview = options.preview
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

  populateDetails: ->
    $(@el).find("#item-show-details").html(@templateShowDetails({item: @model.toJSON()}))

  showSaveOption: ->
    $(".btn-update-item").css("display", "inline");


#Features
# 1. Compare models if anything has changed. Or else hide the show button.