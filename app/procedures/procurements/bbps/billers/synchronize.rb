class Procurements::Bbps::Billers::Synchronize < Transactions::API

  skip_user_authorization!

  step :fetch_all_billers
  step :synchronize_billers

  matcher Dry::Matcher.new(
      Transactions::Matcher::DefaultCases.merge(
          success: Dry::Matcher::Case.new(
              match: -> (result) { result.success? and options['billers.success'].present? and options['billers.failed'].blank? },
              resolve: -> (result) { result }
          ),
          partial_success: Dry::Matcher::Case.new(
              match: -> (result) { result.success? and options['billers.success'].present? and options['billers.failed'].present? },
              resolve: -> (result) { result }
          ),
          failure: Dry::Matcher::Case.new(
              match: -> (result) { result.failure? or options['billers.success'].blank? },
              resolve: -> (result) { result }
          ),
      )
  )

  def fetch_all_billers(context, options)
    ::Bbps::BillersList.(params: {}, 'current_user' => nil) do |m|
      m.success do |result|
        context['billers'] = result
      end
      m.error do |result|
        return on_error options, :base, 'Could not fetch billers'
      end
      m.failure do |result|
        # Todo raise alert as this API cannot fail
        return on_error options, :base, 'Could not fetch billers'
      end
    end
    true
  end

  def synchronize_billers(options, billers:, **)
    options['billers.success'] = []
    options['billers.failed'] = []

    # Limit biller fetching to 100
    billers = billers.first(20) unless Rails.env.production? or Rails.env.uat? or Rails.env.staging?

    billers.each do |biller_config|
      ::Bbps::BillerDetails.(params: {biller_id: biller_config['biller_id']}, 'current_user' => nil) do |m|
        m.success do |result|
          error_message = create_or_update_biller(result)
          if error_message.blank?
            options['billers.success'] << biller_config['biller_id']
          else
            deactivate(biller_config['biller_id'])
            options['billers.failed'] << biller_config.merge({errors: error_message})
          end
        end

        m.error do |result|
          deactivate(biller_config['biller_id'])
          options['billers.failed'] << biller_config.merge({errors: result})
        end

        m.failure do |result|
          deactivate(biller_config['biller_id'])
          options['billers.failed'] << biller_config.merge({errors: result})
        end
      end
    end
    true
  end

  def create_or_update_biller(biller_details)
    biller = BbpsBiller.find_or_initialize_by(biller_id: biller_details['biller_id'])
    return if biller.update(biller_details)

    biller.errors.full_messages.to_sentence
  end

  def deactivate(biller_id)
    BbpsBiller.find_by(biller_id: biller_id)&.update status: 'DEACTIVATED'
  end

end