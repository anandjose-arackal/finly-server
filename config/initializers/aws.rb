# workaround for Aws::VERSION not found error because paperclip
# needs this parameter since aws-sdk made some changes to their gem
# Reference: https://github.com/thoughtbot/paperclip/issues/2484
Aws::VERSION =  Gem.loaded_specs["aws-sdk-s3"].version

################################################
