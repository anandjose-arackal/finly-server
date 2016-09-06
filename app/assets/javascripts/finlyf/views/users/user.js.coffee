class FinlyF.Views.User extends Backbone.View
  templateList: HandlebarsTemplates['finlyf/users/crud/userList']
  template: HandlebarsTemplates['finlyf/users/crud/userSettlements']
  templateShow: HandlebarsTemplates['finlyf/users/crud/show']
  # templateShowDetails: HandlebarsTemplates['finlyf/users/crud/showDetails']
  # templateShow: HandlebarsTemplates['finlyf/reports/crud/show']
  # templateShowDetails: HandlebarsTemplates['finlyf/reports/crud/show_details']
  className: 'user col-md-12'

  events:
    'click .btn-edit-user': 'edit'
    'click .btn-update-user': 'update'

  initialize: (options) ->
    @params = options.params
    @page = options.page

    if @page == 'user'
      @model.fetch({
        data: @params
      })
      @model.on('sync', @populateDetails, @)

  render: ->
    switch @page
      when 'users'
        $(@el).attr('data-item-id', @model.get('id'))
        $(@el).html(@templateList({ item: @model.toJSON() }))
      when 'user'
        $(@el).removeClass('user').addClass('user-details')
        # $(@el).html(@templateShow({ item: @model.toJSON()}))
      when 'settlements'
        $(@el).attr('data-item-id', @model.get('id'))
        $(@el).html(@template({ item: @model.toJSON() }))
    @

  populateDetails: ->
    $(@el).html(@templateShow({item: @model.toJSON()}))

  edit: (e) ->
    target = $(e.currentTarget)
    container = $(target).closest('section')
    $(container).find('.item-attr-preview').addClass('hide')
    $(container).find('.item-attr-edit').addClass('show')
    #edit

    #change edit button to update
    $(target).addClass('success btn-update-user').removeClass('warning btn-edit-user').text('Update')

  update: (e) ->
    target = $(e.currentTarget)
    container = $(target).closest('section')
    values = {}

    _.each($(container).find('form').serializeArray(), (input) ->
      values[ input.name ] = input.value
    )
    values.authenticity_token = $("#authenticity_token").val()

    console.log values
    model = new FinlyF.Models.User({id: @model.get('id')})
    model.save(values, {
      success: (model, res) ->
        console.log model, res
      error: (err) ->
        console.log "Err", err
    })


#Features
# 1. Compare models if anything has changed. Or else hide the show button.