class FinlyF.Views.Analytic extends Backbone.View
  template: HandlebarsTemplates['finlyf/analytics/analytic']
  className: 'item col-md-12 analytic'


  # events:

  initialize: (options) ->
    if @model.get('meta')
      $(@el).addClass('no-padding').removeClass('item analytic')
    # console.log "We're here"

  render: ->
    $(@el).html(@template({item: @model.toJSON()}))
    @