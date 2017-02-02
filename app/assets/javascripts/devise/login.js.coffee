$(document).ready( ->
  $("input[name=email_mobile]").focus().val("")

  Finly = {
    Login: {
      templates: {
        templatePassword: HandlebarsTemplates['finlyf/global/login/password']
      }
    }
  }

  Timer = {
    initialize: ->
      @button = $(".btn-resend-otp");
      @time = 10;
      # this.startTimer();
    

    startTimer: ->
      $(this.button).html("Resend In: <span>00:00</span>").removeClass("btn-warning hidden").addClass('btn-default')
      _this = @
      @time = 60
      @timer = setInterval( ->
        $(_this.button).attr('disabled', 'disabled')
        # // console.log("Time is", _this.time)
        if _this.time == 0
          _this.showResend()
        if _this.time.toString().length == 1
          $(_this.button).find('span').text("00:0" + _this.time.toString())
        else
          $(_this.button).find('span').text("00:" + _this.time.toString())
        _this.time = _this.time - 1
      , 1000)

    showResend: ->
      _this = @
      $(_this.button).attr('disabled', false).html("Resend OTP").addClass('btn-success')
      clearInterval(_this.timer)

    disableVerification: ->
      # // $("")
  }

  Timer.initialize()

  # Go back
  $(".fa-arrow-left").on('click', (e) ->
    loginContainer = $(document).find('.login-container')
    previous_step = "." + $(@).attr('data-back-to')
    current_step = $(@).closest('.steps-login')

    $(current_step).hide('slide', {direction: 'right'}, 100)
    $(previous_step).show('slide', {direction: 'left'}, 200)

    previous_step_height = $(previous_step).attr('data-height-class')
    $(previous_step).closest('.login-container').addClass(previous_step_height)

    $(loginContainer).removeClass('mh-350 mh-420').addClass(previous_step_height)

  )
  # Hanlde Lookup
  handleLookUp = (res, formObjectData) ->
    loginContainer = $(document).find('.login-container')
    stepLookup = $(document).find('.step-lookup')

    if res.success == true
      # User is registered
      # User might might not be verified
      $(stepLookup).hide('slide', {direction: 'left'}, 200)
      if res.verified == true
        # User is verified
        stepPassword = $(loginContainer).find('.step-password')
        $(stepPassword).find('.template-data').html(Finly.Login.templates.templatePassword({item: formObjectData}))
        $(stepPassword).show('slide', {direction: 'right'}, 200)

        $(loginContainer).removeClass('mh-305').addClass('mh-350')
      else
        #User is not verified
        stepVerifyRegistration = $(loginContainer).find('.step-verify-registration')
        $(stepVerifyRegistration).find('input[name=user\\[mobile\\]]').val(formObjectData.email_mobile)
        $(stepVerifyRegistration).find('input[name=mobile_number]').val(formObjectData.email_mobile)

        $(stepVerifyRegistration).show('slide', {direction: 'right'}, 200)
        $(loginContainer).removeClass('mh-305').addClass('mh-420')
    else
      # User is not found on the system
      # User might be deactivated by the admin


  # Validate Phone number or email format
  $("input[name=email_mobile]").on('keyup', (e) ->
    val = $(@).val()

    mobile_patt = /^\d{10}$/
    email_patt = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    if mobile_patt.test(val) || email_patt.test(val)
      $(".login-container #btn-lookup-username").removeAttr('disabled')
    else
      $(".login-container #btn-lookup-username").attr('disabled', 'disabled')
  )

  #Validating OTP format
  $("input[type=number].input-otp").on('keyup', (e) ->
    val = $(@).val()

    console.log "Entering data."

    otp_patt = /^\d{6}$/
    if otp_patt.test(val)
      console.log "Should remove attr"
      $(".login-container .step-verify-registration .btn-verify-otp").removeAttr('disabled')
    else
      console.log "Should not remove attr"
      $(".login-container .step-verify-registration .btn-verify-otp").attr('disabled')
  )

  # Determining if user is registered, verified => Goes to handleLookup()
  $("#form-lookup").on('submit', (e) ->
    form = @
    e.preventDefault()
    console.log "PRevented"

    stepLookup = $(form).closest('.step-lookup')

    # values = $(form).serialize()
    formObjectData = $(form).serializeObject()
    console.log formObjectData


    $.ajax({
      url: $(form).attr('action'),
      # url: '/lookup',
      dataType: 'JSON',
      data: formObjectData,
      success: (res) ->
        handleLookUp(res, formObjectData)
        # console.log "Respnose", res
        # $(stepLookup).hide('slide', {direction: 'left'}, 200)
      error: (err) ->
        console.log "Error", err
    })
  )

  # Logging in User
  $("#form-login").on('submit', (e) ->
    form = @
    e.preventDefault()
    console.log "Prevented Login"

    stepLookup = $(form).closest('.step-lookup')

    values = $(form).serialize()
    # console.log values

    $.ajax({
      url: $(form).attr('action'),
      # url: '/lookup',
      dataType: 'JSON',
      type: $(form).attr('method'),
      data: values,
      success: (res) ->
        console.log res
        window.location.reload()
        # if res.success == true
        #   console.log "Respnose", res, "Logged in"
        # $(stepLookup).hide('slide', {direction: 'left'}, 200)
      error: (err) ->
        res = JSON.parse(err.responseText)
        alert res.error
    })
    # request.error((httpObj, textStatus) ->
    #   if(httpObj.status==401)
    #     console.log textStatus
    #   else
    #     console.log textStatus
    # )
  )

  # Send OTP for the first time
  $(".btn-send-otp").on('click', (e) ->
    e.preventDefault()
    e.stopPropagation()
    button = @
    $(button).attr('disabled', 'disabled')

    stepContainer = $(button).closest('.steps-login')

    $.ajax({
      url: $(button).attr('data-url'),
      dataType: "JSON",
      type: "POST",
      data: {
        authenticity_token: $("#authenticity_token").val()
        mobile_number: $(stepContainer).find("input[name=mobile_number]").val()
      },
      success: (res) ->
        Timer.startTimer()
      error: (err) ->
        # Timer.startTimer()
        $(button).removeAttr('disabled')
        console.log("Error", err)
    })
  )

  # Resend OTPs after the first time
  $(".btn-resend-top").on('click', (e) ->
    e.preventDefault()
    e.stopPropagation()
    button = @

    $(button).attr('disabled', 'disabled')

    stepContainer = $(button).closest('.steps-login')
    $.ajax({
      url: $(button).attr('data-url'),
      dataType: "JSON",
      type: "POST",
      data: {
        authenticity_token: $("#authenticity_token").val()
        mobile_number: $(stepContainer).find("input[name=mobile_number]").val()
      },
      success: (res) ->
        Timer.startTimer()
      error: (err) ->
        # Timer.startTimer()
        console.log("Error", err)
    })
  )

  # Verify User OTP with database
  $("#form-verify-user-otp").on('submit', (e) ->
    form = @
    e.preventDefault()
    console.log "Prevented Verify User OTP Form"

    stepVerifyUserOtp = $(form).closest('.steps-login')

    # values = $(form).serialize()
    formObjectData = $(form).serializeObject()
    console.log formObjectData


    $.ajax({
      url: $(form).attr('action'),
      # url: '/lookup',
      type: $(form).attr('method'),
      dataType: 'JSON',
      data: formObjectData,
      success: (res) ->
        console.log "Will show password setting form"
        # Show template for setting password for first time 
      error: (err) ->
        console.log "Error", err
    })
  )
)