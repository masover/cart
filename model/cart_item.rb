class CartItem
  include Base
  
  property :count, Integer, :default => 1
  
  belongs_to_entity :item
end