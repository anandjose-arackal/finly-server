class FinlyF.Views.Expense extends Backbone.View
  template: HandlebarsTemplates['finlyf/expenses/expense']
  className: 'expense col-md-12'

  render: ->
    $(@el).html(@template({ expense: @model.toJSON() }))
    @