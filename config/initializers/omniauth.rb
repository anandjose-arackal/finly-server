Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production?
    provider :quickbooks, 'qyprdcbNAAUAdPe5BTq7VVoSohnmb9', 'canDspIG9JUVXNLqle2zGzw2dACOOubtjkyt8LRv'
  else
    provider :quickbooks, 'qyprd0zDADfuZkLhAUxBfCWOZD9arh', 'UmdQJxfAd5Y7VZlCxF1gACyz60HWgI1hEXGkZImj'
  end

  # adding multiple SAML configurations here for authentication
  OmniAuth::MultiProvider.register(self,
                                   provider_name: :saml,
                                   identity_provider_id_regex: /\d+/,
                                   path_prefix: '/auth/saml',
                                   callback_suffix: 'callback',
                                   # Specify any additional provider specific options
                                   name_identifier_format: 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress',
                                   issuer: 'salsify.com',
                                   allowed_clock_drift: 5.seconds) do |identity_provider_id, rack_env|
    identity_provider = SAML::IdentityProvider.find(identity_provider_id)
    # Optionally store a reference to the identity provider in the Rack environment
    # so you can reference it in your OmniAuth callbacks controller
    rack_env['salsify.saml_identity_provider'] = identity_provider
    # Any dynamic options returned by this block will be merged in with any statically
    # configured options for the identity provider type e.g. issuer in this example.
    identity_provider.options
  end
end