class FinlyF.Views.FAQ extends Backbone.View
  template: HandlebarsTemplates['finlyf/faq/skeleton']

  initialize: (options) ->
    @params = options.params
    @params.view = @params.view || 'personal'


  render: ->
    $(@el).html(@template())
    loader_div = $(@el).find('.container-main')
    FinlyF.startMainLoader(loader_div)
    @populateFAQ()
    console.log "Params", @params
    FinlyF.structureActions(@el, @params)
    @

  populateFAQ: ->
    _this = @
    $.ajax({
      url: '/faqs'
      dataType: 'html'
      success: (res) ->
        FinlyF.stopMainLoader()
        $(_this.el).find(".main.main-faqs").html(res)
      error: (err) ->
        console.log "Error", err
    })
