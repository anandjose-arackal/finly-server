# class FinlyF.Views.Statement extends Backbone.View
#   templateSkeleton: HandlebarsTemplates['finlyf/statements/base/skeleton']
#   templateSidebar: HandlebarsTemplates['finlyf/statements/sidebar/sidebar']
#   templateNavbarMain: HandlebarsTemplates['finlyf/statements/navbar/navbar_main']

#   events:
#     'click .filter-statements': 'filterStatements'

#   initialize: (options) ->
#     if options
#       @user = options.user
#       @params = options.params


#   render: ->
#     $(@el).html(@templateSkeleton({item: @params}))
#     $(@el).find(".sidebar").html(@templateSidebar())
#     $(@el).find(".navbar-main").html(@templateNavbarMain())
#     # $(@el).find(".settlements-index").html(@templateMainPayments())

#     FinlyF.structureActions(@el, @params)
#     @


#   filterStatements: (e) ->
#    e.preventDefault()
#     target = e.currentTarget

#     @params.filter_state = parseInt($(target).attr('data-filter-state')) 

#   # fetchStatements: ->
    

