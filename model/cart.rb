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
  
  def checkout!
    if self.state == 'browse'
      transaction do
        reload
        if self.state == 'browse'
          self.state = 'checkout'
          save
        end
      end
    end
    if self.state == 'checkout'
      cart_items.each do |cart_item|
        cart_item.item.update_transaction! self, cart_item.count
      end
      
      transaction do
        reload
        if self.state == 'checkout'
          self.state = 'complete'
          save
        end
      end
      
      if self.state == 'complete'
        cart_items.each do |cart_item|
          cart_item.item.update_transaction! self, cart_item.count
        end
      end
    end
  end
end