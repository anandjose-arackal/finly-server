class FinlyF.Views.Settlement extends Backbone.View
  template: HandlebarsTemplates['finlyf/settlements/crud/settlement']
  templateReport: HandlebarsTemplates['finlyf/settlements/crud/settlementReport']
  templateRequest: HandlebarsTemplates['finlyf/settlements/crud/settlementRequest']#money request
  templateMainPayments: HandlebarsTemplates['finlyf/settlements/crud/payment']
  templateMainRequest: HandlebarsTemplates['finlyf/settlements/crud/request']
  # templateShow: HandlebarsTemplates['finlyf/reports/crud/show']
  # templateShowDetails: HandlebarsTemplates['finlyf/reports/crud/show_details']
  className: 'item col-md-12'

  events:
    'click .select-item': 'toggleSelect'

  initialize: (options) ->
    console.log "options", options
    if options
      @page = options.page
    # console.log "Will render settlement"
    # console.log @model.toJSON()

  render: ->
    if @page
      if @page == 'reimburse' || @page == 'settle_debt'
        $(@el).removeClass('item').addClass('settlement-report')
        $(@el).html(@templateReport({ item: @model.toJSON() }))
      else if @page == 'money_request'
        $(@el).removeClass('item').addClass('settlement-report')
        $(@el).html(@templateRequest({item: @model.toJSON() }))
      else
        if @model.get('type') == 'payment'
          $(@el).html(@templateMainPayments({item: @model.toJSON()}))
        else
          $(@el).html(@template({item: @model.toJSON()}))
    else
      if @model.get('type') == 'payment'
        $(@el).html(@templateMainPayments({item: @model.toJSON()}))
      else if @model.get('type') == 'money_request'
        $(@el).html(@templateMainRequest({item: @model.toJSON()}))
      else
        $(@el).html(@template({item: @model.toJSON()}))
    @

  toggleSelect: (e) ->
    if $(e.currentTarget).prop('checked')
      $(@el).addClass('selected')
    else
      $(@el).removeClass('selected')


#Features
# 1. Compare models if anything has changed. Or else hide the show button.