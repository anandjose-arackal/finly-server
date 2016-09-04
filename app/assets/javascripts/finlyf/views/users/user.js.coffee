class FinlyF.Views.User extends Backbone.View
  templateList: HandlebarsTemplates['finlyf/users/crud/userList']
  template: HandlebarsTemplates['finlyf/users/crud/userSettlements']
  templateShow: HandlebarsTemplates['finlyf/users/crud/show']
  # templateShow: HandlebarsTemplates['finlyf/reports/crud/show']
  # templateShowDetails: HandlebarsTemplates['finlyf/reports/crud/show_details']
  className: 'user col-md-12'

  # events:
    # 'click .select-item': 'toggleSelect'

  initialize: (options) ->
    @page = options.page

    if @page == 'user'
      @model.fetch()
      @model.on('sync', @populateDetails, @)

  render: ->
    switch @page
      when 'users'
        $(@el).attr('data-item-id', @model.get('id'))
        $(@el).html(@templateList({ item: @model.toJSON() }))
      when 'user'
        $(@el).removeClass('user').addClass('user-details')
        $(@el).html(@templateShow({ item: @model.toJSON() }))
      when 'settlements'
        $(@el).attr('data-item-id', @model.get('id'))
        $(@el).html(@template({ item: @model.toJSON() }))
    @

  populateDetails: ->
    console.log @model.toJSON()


#Features
# 1. Compare models if anything has changed. Or else hide the show button.