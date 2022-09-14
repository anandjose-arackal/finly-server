# Todo: Initialize Eager Loaded caches during server start
Rails.logger.debug "Application Cache Init"

# Add below whenever a new Cache is added here
CACHE_REGISTRY = [FormKlassCache, FormDependenciesCache,]

COMPANY_SCOPED_EAGER_CACHES = CACHE_REGISTRY.select {|c| c.company_scoped? and c.eager_loaded?}
