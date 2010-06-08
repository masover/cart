require 'dm-core'
require 'dm-timestamps'

# Used to make updates idempotent.
class ItemUpdateKey
  include Base
  
  property :created_at, DateTime
end