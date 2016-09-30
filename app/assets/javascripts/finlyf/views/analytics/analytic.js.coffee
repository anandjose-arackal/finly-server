class FinlyF.Views.Analytic extends Backbone.View
  template: HandlebarsTemplates['finlyf/analytics/analytic']
  className: 'item col-md-12'


  # events:

  initialize: (options) ->
    console.log "We're here"

  render: ->
    $(@el).html(@template({item: @model.toJSON()}))
    @