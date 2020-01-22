class Docs::UtilityBills::Subscriptions::Ops::ValidateCustomerParams < Trailblazer::Operation
  step :init

  def init(options)
    options['result'] = {}

    if rand > 0.5
      options['result']['success'] = true
      options['result']['customer_email'] = 'demo@example.com'
      options['result']['customer_name'] = 'John Doe'
      options['result']['customer_pan'] = 'AHDUE8373J'
    else
      options['result']['success'] = false
      options['result']['messages'] = {
          'errors' => ['No record found with the provided data']
      }
    end

  end


  def bill_validate(options, params:, current_user:, **)
    op = Bbps::BillValidation.(params, "current_user" => current_user)
    options['result'] = {
        'success' => op.success?,
    }

    # unless op.success?
    #
    # end
  end
end