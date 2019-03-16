Gatekeeper::Checker.new 'Throttling' do

  section 'Lookup' do
    before do
      skip unless RequestStoreUtil.current_request.path.include?('/lookup')
    end

    # rule 'Throttle 10 requests per minute' do
    #   UserSessionEvent
    # end
  end

  section 'Login Attempt' do

  end

  section 'On Authentication' do

  end

end