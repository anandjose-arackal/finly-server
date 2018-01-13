namespace :aws do
  desc 'Enable AWS Secure Storage'
  task :enable_secure_storage do
    type = ENV['STAGE'] == 'itzcash_production' ? :production : :development
    deploy_env_config = YAML.load(File.read("config/deploy/config/#{type}.yml"))
    if deploy_env_config == nil or deploy_env_config&.dig('aws').blank?
      raise 'deploy_config.yml not found or has missing configuration'
    end
    aws = Aws::EC2::Client.new(access_key_id: deploy_env_config&.dig('aws', 'access_key_id'),
                               secret_access_key: deploy_env_config&.dig('aws', 'secret_access_key'),
                               region: deploy_env_config&.dig('aws', 'region'))
    aws.authorize_security_group_ingress(deploy_env_config&.dig('aws', 'params'))
  end

  desc 'Disable AWS Secure Storage'
  task :disable_secure_storage do
    type = ENV['STAGE'] == 'itzcash_production' ? :production : :development
    deploy_env_config = YAML.load(File.read("config/deploy/config/#{type}.yml"))
    if deploy_env_config == nil or deploy_env_config&.dig('aws').blank?
      raise 'deploy_config.yml not found or has missing configuration'
    end
    aws = Aws::EC2::Client.new(access_key_id: deploy_env_config&.dig('aws', 'access_key_id'),
                               secret_access_key: deploy_env_config&.dig('aws', 'secret_access_key'),
                               region: deploy_env_config&.dig('aws', 'region'))
    aws.revoke_security_group_ingress(deploy_env_config&.dig('aws', 'params'))
  end
end
