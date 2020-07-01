if Socket.gethostname == "finly-core-bgg"
  require 'objspace'
  ObjectSpace.trace_object_allocations_start
end