# workaround for Aws::VERSION not found error because paperclip
# needs this parameter since aws-
Aws::VERSION =  Gem.loaded_specs["aws-sdk"].version
