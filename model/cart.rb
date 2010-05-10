class Cart
  include Base
  
  property :state, String, :default => 'browse'
  has_descendants :cart_items
  
  def set_item! item, count
    item.update_transaction! self, count
    transaction do
      cart_item = cart_items.first :item_id => item.id
      if count == 0
        cart_item.destroy unless cart_item.nil?
      else
        if cart_item.nil?
          CartItem.create :id => {:parent => id}, :item => item, :count => count
        else
          cart_item.update :count => count
        end
      end
    end
  end
end