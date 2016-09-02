class FinlyF.Views.Report extends Backbone.View
  template: HandlebarsTemplates['finlyf/reports/crud/report']
  templateShow: HandlebarsTemplates['finlyf/reports/crud/show']
  templateShowDetails: HandlebarsTemplates['finlyf/reports/crud/show_details']

  templateNewExpense: HandlebarsTemplates['finlyf/expenses/new']
  templateExistingExpense: HandlebarsTemplates['finlyf/reports/expenses/existingExpenses']
  className: 'item col-sm-12'

  events:
    'click .select-item': 'toggleSelect'
    'input [contenteditable=true]': 'updateModel'
    'click .btn-update-item': 'update'
    'click .add-new-expense': 'newExpense'
    'click .add-existing-expense': 'existingExpense'
    'click .btn-create-expense': 'createExpense'
    'click .btn-post-comment': 'postComment'

    'click .btn-delete-item': 'delete'
    'click .btn-delete-sub-item': 'deleteSub'
    'click .btn-edit-item': 'edit'
    'click .btn-update-item': 'update'
    'click .btn-submit-item': 'submit'
    'click .btn-retract-item': 'retract'

  initialize: (options) ->
    @parent = options.parent
    _this = @
    @preview = options.preview
    data = {}
    if @preview
      @current_view = options.current_view ##NEED TO ADD THIS IN REPORTS
      if @current_view
        data.view = @current_view
      $(@el).removeClass("item").addClass("bg-white")
      @model.fetch({data: data})
    @model.on('sync', @populateDetails, @)
    @model.on('change', @showSaveOption, @)
    

  render: ->
    unless @preview
      $(@el).html(@template({ item: @model.toJSON() }))
    else
      $(@el).html(@templateShow())
    @

  updateModel: (e) ->
    # _this = @
    field = $(e.target).attr('data-field')
    value = e.target.innerText
    @model.set(field, value);

  update: ->
    @model.save({patch: true})

  toggleSelect: (e) ->
    if $(e.currentTarget).prop('checked')
      $(@el).addClass('selected')
    else
      $(@el).removeClass('selected')

  populateDetails: ->
    @model.set('current_view', @current_view)
    $(@el).find("#item-show-details").html(@templateShowDetails({item: @model.toJSON()}))

  showSaveOption: ->
    $(".btn-update-item").css("display", "inline");

  newExpense: (e) ->
    _this = @
    data = {
      report_id: $(e.currentTarget).attr('data-item-id')
    }
    $("#modal-new .modal-body").html(@templateNewExpense({data: data}))
    $("#modal-new .modal-body").find("[name=authenticity_token]").val($("#authenticity_token").val())

    #Populate categories from index.json.jbuilder  
    category_select = $("#modal-new .modal-body").find(".newExpenseCategory")
    options = $("#newExpenseCategory option")
    for option in options
      $('<option/>', {
        value: $(option).attr('value')
        text: $(option).text()
      }).appendTo(category_select) 
    
    $("#modal-new").modal('show')
    $("#modal-new").find('.btn-create-expense').on('click', (e) ->
      _this.createExpense(@);
    )

  createExpense: (e) ->
    _this =   @
    values = {}

    # if(event){ event.preventDefault(); }

    _.each($("#modal-new form#new-item").serializeArray(), (input) ->
      values[ input.name ] = input.value
    )
    console.log values
    model = new FinlyF.Models.Expense()
    # console.log("Putting data")
    response = model.save(values, {
      iframe: true,
      files: this.$('form :file'),
      data: values
      processData: true
      success: (model, res) ->
        $("#modal-new").modal('hide')
        _this.model.fetch()
      error: (err) ->
        console.log "Error", err
    })

    console.log response

  existingExpense: (e) ->
    report_id = $(e.currentTarget).attr('data-item-id')
    expense_view = new FinlyF.Views.ExpensesIndex({
      indexOnly: true
    })
    $(@el).find("#modal-mp .modal-content").html(@templateExistingExpense())
    $(@el).find("#modal-mp .modal-content .modal-body").html(expense_view.render().el)
    $(@el).find("#modal-mp").modal('show')

  edit: (e) ->
    #Warning!!! Dirty codes ahead!
    $(e.currentTarget).addClass('btn-update-item btn-success').removeClass('btn-edit-item btn-warning').html("Update  <i class='fa fa-check'></i>")

    _this = @
    $(@el).find(".item-name").html("<input type='text' class='item-name-edit' />")
    $(@el).find(".item-name .item-name-edit").val(_this.model.get('name'))

    target_select = $(@el).find(".item-policy")
    select = $('<select />', {
      name: 'item-policy',
      class: 'item-policy-edit',

    })

    policies = $(@model.get('policies'))
    for policy in policies
      console.log policy
      $('<option />', {
        text: policy.name,
        value: policy.id
      }).appendTo(select)

    $(target_select).html(select)

  update: (e) ->
    $(e.currentTarget).html("<i class='fa fa-circle-o-notch fa-spin'></i>")
    _this = @

    policy_id = $(@el).find('select.item-policy-edit').val()
    name = $(@el).find('input.item-name-edit').val()
    
    @model.save({report: {name: name}}, {
      success: (model, res) ->
        console.log model, res
      error: (err) ->
        console.log "Error", err
    })

    ##Below code is not needed, as the model sync will reload the view!
    # $(@el).find(".item-name").html(@model.get('name'))
    # $(@el).find(".item-policy").html(@model.get('policy') || "None")
    # $(@el).find(".item-name .item-name-edit").val(_this.model.get('name'))
    # $(e.currentTarget).addClass('btn-edit-item btn-warning').removeClass('btn-update-item btn-success').html("Edit  <i class='fa fa-edit'></i>")

  postComment: (e) ->
    _this = @
    target = $(e.currentTarget)
    report_id = $(target).attr('data-item-id')
    data = {
      comment: $(target).closest('.form-new-comment').find('.comment-content').val()
    }

    # @model.set('comment', comment)
    model = new FinlyF.Models.Report(data)
    model.urlRoot = '/reports/' + report_id + '/comment'
    model.save(null, {
      success: (model, res) ->
        console.log model, res
        _this.model.fetch()
      error: (err) ->
        console.log "Error", err
    })
    # console.log report_id

  delete: (e) ->
    _this = @
    # @model.set('authenticity_token', $("#authenticity_token").val())
    console.log $("#authenticity_token").val()
    @model.destroy({
      data: {
        'authenticity_token': $("#authenticity_token").val()
      }
      processData: true
      success: (model, res) ->
        console.log res
        _this.parent.trigger('item:destroyed')
      error: (err) ->
        console.log "Error", err

    })

  deleteSub: (e) ->
    console.log "deleteing sub"
    _this = @
    expense_id = $(e.currentTarget).attr('data-item-id')
    $.ajax({
      url: _this.model.urlRoot + "/" + _this.model.get('id') + "/remove_expenses?expense_id=" + expense_id,
      type: 'DELETE',
      dataType: 'json',
      data: {
        authenticity_token: $("#authenticity_token").val()
      },
      success: (res)->
        _this.model.fetch()
      error: (err) ->
        console.log "Error", err
    })

  submit: (e) ->
    _this = @
    report_id = @model.get('id')

    $.ajax({
      url: "/reports/" + report_id + "/submit",
      dataType: 'json',
      data: {
        report_id: report_id,
        authenticity_token: $("#authenticity_token").val()
      },
      type: 'PATCH',
      success: (res) ->
        console.log res
        _this.model.fetch()
      error: (err) ->
        console.log err
    })

  retract: (e) ->
    e.preventDefault()
    _this = @
    report_id = @model.get('id')

    $.ajax({
      url: "/reports/" + report_id + "/retract",
      dataType: 'json',
      data: {
        report_id: report_id,
        authenticity_token: $("#authenticity_token").val()
      },
      type: 'PATCH',
      success: (res) ->
        # console.log res
        _this.model.fetch()
      error: (err) ->
        console.log err
    })




