class FinlyF.Views.ExpensesIndex extends Backbone.View

  template: HandlebarsTemplates['finlyf/expenses/index']

  initialize: ->
    console.log "Step x. Init View"
    @collection = new FinlyF.Collections.Expenses()
    @collection.fetch({reset: true})
    @collection.on('reset', @processExpenses, @)

  render: ->
    console.log "Step 3. Rendeing."
    $(@el).html(@template())
    @

  processExpenses: ->
    @collection.each(@appendExpense, @)

  appendExpense: (expense) ->
    view_expense = new FinlyF.Views.Expense({ model: expense })
    $(@el).find("#expenses").append(view_expense.render().el)