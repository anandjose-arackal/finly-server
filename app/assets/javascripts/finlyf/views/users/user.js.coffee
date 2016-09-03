class FinlyF.Views.User extends Backbone.View
  template: HandlebarsTemplates['finlyf/users/crud/userSettlements']
  # templateShow: HandlebarsTemplates['finlyf/reports/crud/show']
  # templateShowDetails: HandlebarsTemplates['finlyf/reports/crud/show_details']
  className: 'user col-md-12'

  # events:
    # 'click .select-item': 'toggleSelect'

  initialize: (options) ->
    # console.log "Will render settlement"
    # console.log @model.toJSON()

  render: ->
    $(@el).html(@template({ item: @model.toJSON() }))
    @

  # toggleSelect: (e) ->
  #   if $(e.currentTarget).prop('checked')
  #     $(@el).addClass('selected')
  #   else
  #     $(@el).removeClass('selected')


#Features
# 1. Compare models if anything has changed. Or else hide the show button.