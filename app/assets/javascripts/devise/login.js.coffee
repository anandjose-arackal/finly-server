$(document).ready( ->
  $(document).find("input[type=text][type=number][type=password]").val("")
  $("input[name=email_mobile]").focus()

  Finly = {
    Login: {
      templates: {
        templatePassword: HandlebarsTemplates['finlyf/global/login/password']
      }
      regex: {
        mobile_patt: /^\d{10}$/
        email_patt: /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
        otp_patt: /^\d{6}$/
      }
      heights: [
        'mh-340'
        'mh-390'
        'mh-405'
        'mh-438'
        'mh-455'
      ]
      snapNotify: (obj) ->
        ohSnapX()
        for type, messages of obj
          switch type
            when 'error'
              color = 'red'
              container = 'ohsnap-priority'
            when 'success'
              color = 'green'
              container = 'ohsnap'
            when 'failure'
              color: 'orange'
              container = 'ohsnap-priority'
            when 'message'
              color: 'blue'
              container = 'ohsnap'
            when 'notice'
              color: 'blue'
              container = 'ohsnap'
            else
              color: 'blue'
              container = 'ohsnap'
          if messages.length
            for message in messages
              # console.log "Message ", message, "Color:", color, "container", container
              ohSnap(message, {color: color, 'duration': '9000', 'container-id': container})
    }
  }

  Timer = {
    initialize: ->
      @button = $(".btn-resend-otp")
      @time = 10
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

    resetEverything: ->
      _this = @
      if @timer
        clearInterval(@timer)
      $(@button).attr('disabled', 'disabled').addClass('hidden')

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

    $(loginContainer).removeClass(Finly.Login.heights.join(" ")).addClass(previous_step_height)

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
        if Finly.Login.regex.mobile_patt.test(formObjectData.email_mobile)
          formObjectData.type = 'mobile'
        else if Finly.Login.regex.email_patt.test(formObjectData.email_mobile)
          formObjectData.type = 'email'

        stepPassword = $(loginContainer).find('.step-password')
        heightClass = $(stepPassword).attr('data-height-class')
        $(stepPassword).find('.template-data').html(Finly.Login.templates.templatePassword({item: formObjectData}))
        $(stepPassword).show('slide', {direction: 'right'}, 200)
        $(loginContainer).removeClass(Finly.Login.heights.join(" ")).addClass(heightClass)
        setTimeout(->
          $(stepPassword).find("input[type=password]").focus()
        , 300)
        # $(stepPassword).find("input[type=password]").focus()

      else
        #User is not verified
        stepVerifyRegistration = $(loginContainer).find('.step-verify-registration')
        heightClass = $(stepVerifyRegistration).attr('data-height-class')
        $(stepVerifyRegistration).find("button.btn-send-otp").removeAttr('disabled')
        Timer.resetEverything()

        if Finly.Login.regex.mobile_patt.test(formObjectData.email_mobile)
          # $(stepVerifyRegistration).find('input[name=user\\[mobile\\]]').val(formObjectData.email_mobile)
          $(stepVerifyRegistration).find('input[name=mobile_number]').val(formObjectData.email_mobile)
        else if Finly.Login.regex.email_patt.test(formObjectData.email_mobile)
          # $(stepVerifyRegistration).find('input[name=user\\[mobile\\]]').val('')
          $(stepVerifyRegistration).find('input[name=mobile_number]').val('').removeAttr('readonly')
        
        

        $(stepVerifyRegistration).show('slide', {direction: 'right'}, 200)
        $(loginContainer).removeClass(Finly.Login.heights.join(" ")).addClass(heightClass)
    else
      Finly.Login.snapNotify(res.messages)
      # User is not found on the system
      # User might be deactivated by the admin

  handleLookupReset = (res, formObjectData) ->
    loginContainer = $(document).find('.login-container')
    stepResetPasswordOption = $(document).find('.step-reset-password-options')
    stepLookup = $(document).find(".step-lookup")

    if res.success == true
      if Finly.Login.regex.mobile_patt.test(formObjectData.email_mobile)
        $(stepResetPasswordOption).hide('slide', {direction: 'left'}, 100)
        stepVerifyRegistration = $(loginContainer).find('.step-verify-registration')
        heightClass = $(stepVerifyRegistration).attr('data-height-class')
        $(stepVerifyRegistration).find('input[name=user\\[mobile\\]]').val(formObjectData.email_mobile)
        $(stepVerifyRegistration).find('input[name=mobile_number]').val(formObjectData.email_mobile)

        $(stepVerifyRegistration).show('slide', {direction: 'right'}, 200)
        $(loginContainer).removeClass(Finly.Login.heights.join(" ")).addClass(heightClass)
      else if Finly.Login.regex.email_patt.test(formObjectData.email_mobile)
        console.log "Something"
        $.ajax({
          url: "/users/password",
          dataType: 'json',
          type: "POST"
          data: {
            user: {
              email: formObjectData.email_mobile
            }
            authenticity_token: $("#authenticity_token").val()
          }
          success: (res) ->
            Finly.Login.snapNotify(res.messages)
            if res.success == true
              $(stepResetPasswordOption).hide('slide', {direction: 'right'}, 200)
              $(stepLookup).show('slide', {direction: 'left'}, 200)
              heightClass = $(stepLookup).attr('data-height-class')
              $(loginContainer).removeClass(Finly.Login.heights.join(" ")).addClass(heightClass)



            console.log "Res", res
          error: (err) ->
            console.log "Err", err
        })
    else
      Finly.Login.snapNotify(res.messages)
      # User is not found on the system
      # User might be deactivated by the admin


  # Validate Phone number or email format
  # $("input[name=email_mobile]").on('keyup focusout focus click change', (e) ->
  #   val = $(@).val()

  #   if Finly.Login.regex.mobile_patt.test(val) || Finly.Login.regex.email_patt.test(val)
  #     $(".login-container #btn-lookup-username").removeAttr('disabled')
  #   else
  #     $(".login-container #btn-lookup-username").attr('disabled', 'disabled')
  # )

  #Validating OTP format
  $("input[type=number].input-otp").on('keyup', (e) ->
    val = $(@).val()
    if Finly.Login.regex.otp_patt.test(val)
      console.log "Should remove attr"
      $(".login-container .step-verify-registration .btn-verify-otp").removeAttr('disabled')
    else
      console.log "Should not remove attr"
      $(".login-container .step-verify-registration .btn-verify-otp").attr('disabled')
  )

  # Lookup: Determining if user is registered, verified => Goes to handleLookup()
  $("#form-lookup").on('submit', (e) ->
    form = @
    e.preventDefault()

    email_mobile = $(@).find("input[name=email_mobile]").val()
    unless Finly.Login.regex.mobile_patt.test(email_mobile) || Finly.Login.regex.email_patt.test(email_mobile)
      # $(".login-container #btn-lookup-username").removeAttr('disabled')
      ohSnap('Enter A Valid Email Or 10 Digit Mobile Number', {color: 'red', 'duration': '9000', 'container-id': 'ohsnap-priority'})
    else
      stepLookup = $(form).closest('.step-lookup')
      formObjectData = $(form).serializeObject()

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
    $(form).find("input[type=submit]").val("Logging In...").attr('disabled', 'disabled')

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
        if res.success == true
          window.location.reload()
        else
          $(form).find("input[type=submit]").val("Login").removeAttr('disabled')
      error: (err) ->
        res = JSON.parse(err.responseText)
        $(form).find("input[type=submit]").val("Login").removeAttr('disabled')
        # alert res.error
        ohSnap(res.error, {color: 'red', 'duration': '9000', 'container-id': 'ohsnap-priority'})
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
        Finly.Login.snapNotify(res.messages)
        if res.success == true
          Timer.startTimer()
        else
          $(button).removeAttr('disabled')
      error: (err) ->
        # Timer.startTimer()
        $(button).removeAttr('disabled')
        console.log("Error", err)
    })
  )

  # Resend OTPs after the first time
  $(".btn-resend-otp").on('click', (e) ->
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

  handleResetPassword = (res, formObjectData) ->
    # if res.success == true

    loginContainer = $(document).find('.login-container')
    stepVerifyUserOtp = $(document).find('.step-verify-registration')
    stepResetPassword = $(document).find('.step-reset-password')

    heightClass = $(stepResetPassword).attr('data-height-class')

    $(stepVerifyUserOtp).hide('slide', {direction: 'left'}, 200)
    $(stepResetPassword).show('slide', {direction: 'right'}, 200)
    $(loginContainer).removeClass(Finly.Login.heights.join(' ')).addClass(heightClass)


    $(stepResetPassword).find("input[name=user\\[mobile_number\\]]").val(formObjectData.mobile_number)

  # Verify User OTP with database
  $("#form-verify-user-otp").on('submit', (e) ->
    form = @
    e.preventDefault()
    # console.log "Prevented Verify User OTP Form"

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
        Finly.Login.snapNotify(res.messages)
        if res.success == true
          handleResetPassword(res, formObjectData)
        # console.log "Will show password setting form"
        # Show template for setting password for first time 
      error: (err) ->
        console.log "Error", err
        # handleResetPassword(err, formObjectData)
    })
  )

  $("#form-reset-password").on('submit', (e) ->
    e.preventDefault()
    e.stopPropagation()
    form = @

    console.log "Prevented set password."

    submit = $(form).find("input[type=submit]")
    $(submit).attr('disabled', 'disabled').val("Please Wait...")


    formObjectData = $(form).serializeObject()

    $.ajax({
      url: $(form).attr('action'),
      type: $(form).attr('method'),
      dataType: 'JSON',
      data: formObjectData,
      success: (res) ->
        Finly.Login.snapNotify(res.messages)
        # console.log "Success", res
        if res.success == true
          window.location.reload()
        else
          $(submit).removeAttr('disabled').val("Create Password & Login")
      error: (err) ->
        $(submit).removeAttr('disabled').val("Create Password & Login")
       
    })

  )

  $(".a-forgot-password").on('click', (e) ->
    # console.log "Shouldn't submit the form"
    e.preventDefault()
    e.stopPropagation()

    loginContainer = $(@).closest('.login-container')
    stepCurrent = $(@).closest('.steps-login')
    stepResetPasswordOption = $(document).find('.login-container .step-reset-password-options')
    heightClass = $(stepResetPasswordOption).attr('data-height-class')


    if $(stepCurrent).hasClass('step-lookup')
      email_mobile = $(stepCurrent).find("input[name=email_mobile]").val()
      # Extract email_mobile if any
    else if $(stepCurrent).hasClass('step-password')
      # Extract from Label
      email_mobile = $(stepCurrent).find("input[name=user\\[email\\]]").val()

    if Finly.Login.regex.mobile_patt.test(email_mobile)
      $('a[href="#reset-by-mobile"]').tab('show')
      $(stepResetPasswordOption).find("input[name=user\\[mobile_number\\]]").val(email_mobile)
    else if Finly.Login.regex.email_patt.test(email_mobile)
      $('a[href="#reset-by-email"]').tab('show')
      $(stepResetPasswordOption).find("input[name=user\\[email\\]]").val(email_mobile)

    console.log 'Adding Height', heightClass
    $(loginContainer).removeClass(Finly.Login.heights.join(' ')).addClass(heightClass)
    
    $(stepCurrent).hide('slide', {direction: 'left'}, 100)
    $(stepResetPasswordOption).show('slide', {direction: 'right'}, 200)
    # a = @
    # container = $(@).closest('.steps-login')
    # $(container).find('.btn-reset-password').removeClass('hidden')
  )

  $("#form-init-reset-password").on('submit', (e) ->
    e.preventDefault()
    e.stopPropagation()

    form = @
    formObjectData = {}
    active_pane = $(form).find(".tab-pane.active")
    if $(active_pane).attr('data-reset-by') == 'mobile'
      formObjectData.email_mobile = $(active_pane).find("input[name=user\\[mobile_number\\]]").val()
    else if $(active_pane).attr('data-reset-by') == 'email'
      formObjectData.email_mobile = $(active_pane).find("input[name=user\\[email\\]]").val()

    $.ajax({
      url: $(form).attr('action'),
      # url: '/lookup',
      dataType: 'JSON',
      data: formObjectData,
      success: (res) ->
        # Finly.Login.snapNotify(res.messages)
        # if res.success == true
        handleLookupReset(res, formObjectData)
        # handleLookUp(res, formObjectData)
        # console.log "Respnose", res
        # $(stepLookup).hide('slide', {direction: 'left'}, 200)
      error: (err) ->
        console.log "Error", err
    })
  )
)
