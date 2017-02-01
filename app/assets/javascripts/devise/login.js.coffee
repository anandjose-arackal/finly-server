$(document).ready( ->

  Finly.Login = {
    
  }

  # Hanlde Lookup
  handleLookUp = (res) ->
    console.log "Response", res

  $("#form-lookup").on('submit', (e) ->
    e.preventDefault()

    stepLookup = $(@).closest('.step-lookup')

    values = $(@).serialize()
    console.log values

    $.ajax({
      # url: $(@).attr('action'),
      url: '/lookup',
      dataType: 'JSON'
      type: $(@).attr('method'),
      data: values,
      success: (res) ->
        console.log "Respnose", res
      error: (err) ->
        console.log "Error", err
        $(stepLookup).hide('slide', {direction: 'left'}, 200)
      done: ->
        console.log "Done"
        $(stepLookup).hide('slide', {direction: 'left'}, 200)


    })


  )

)