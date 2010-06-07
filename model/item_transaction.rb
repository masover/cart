require 'dm-core'
require 'dm-timestamps'

class ItemTransaction
  include Base
  
  property :count, Integer, :default => 1
  
  belongs_to_entity :cart
  
  property :updated_at, DateTime
end