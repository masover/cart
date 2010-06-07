require 'dm-core'
require 'dm-timestamps'

class Cart
  include Base
  
  property :state, String, :default => 'browse'
  property :updated_at, DateTime
  
  has_descendants :cart_items
  
  before :destroy do
    self.class.rollback_transactions_for self.id
  end
  
  def self.rollback_transactions_for cart_id
    AppEngine::Labs::TaskQueue.add nil, :method => 'DELETE', :url => "/carts/#{cart_id}/transactions"
  end
  
  def add_item! item
    # Not transactional. We assume a single user won't race themself.
    cart_item = cart_items.first :item_id => item.id
    # Add a single item to the cart if it wasn't there already.
    set_item! item, 1 if cart_item.nil?
  end
  
  def set_item! item, count
    item.update_transaction! self, count
    transaction do
      reload
      if state != 'browse'
        raise "Can't change values once checking out!"
      end
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
      # Hack to force an update
      self.updated_at = nil
      save
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