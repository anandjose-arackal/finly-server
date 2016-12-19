class FinlyF.Views.FAQ extends Backbone.View
  template: HandlebarsTemplates['finlyf/faq/skeleton']

  initialize: ->
    @params = {}
    @params.view = 'personal'

  render: ->
    $(@el).html(@template())
    @populateFAQ()
    FinlyF.structureActions(@el, @params)
    @

  populateFAQ: ->
    _this = @
    $.ajax({
      url: '/faqs'
      dataType: 'html'
      success: (res) ->
        $(_this.el).find(".main.main-faqs").html(res)
      error: (err) ->
        console.log "Error", err
    })
