class Item
  include Base
  
  property :name, String, :required => true
  property :description, Text
  property :stock, Integer, :default => 0
  
  has_descendants :item_transactions
  has_descendants :update_keys
  
  attr_accessor :delta
  attr_reader :update_key
  
  def update_key= value
    @update_key = AppEngine::Datastore::Key.new value
  end
  
  def get_update_key
    UpdateKey.create :id => {:parent => self.id}
  end
  
  def save
    if delta.nil? || delta == 0
      super || (return false)
    else
      attrs = dirty_attributes
      transaction do
        key = update_keys.first(:id => update_key)
        raise AppEngine::Datastore::Rollback if key.nil?
        key.destroy
        reload
        old_stock = self.stock
        self.attributes = attrs
        self.stock = old_stock + delta.to_i
        super || (return false)
      end
      if dirty?
        super || (return false)
      end
      @update_key = nil
      @delta = nil
    end
    true
  end
  
  def update_transaction! cart, count
    state = cart.state
    
    transaction do
      debit = count
      item_transaction = item_transactions.first :cart_id => cart.id
      if item_transaction.nil?
        if count == 0 || state == 'complete'
          debit = 0 # If it's complete, assume we've already debited.
        else
          ItemTransaction.create :id => {:parent => id}, :cart => cart, :count => count
        end
      else
        debit -= item_transaction.count
        if count == 0 || state == 'complete'
          item_transaction.destroy
        else
          item_transaction.update :count => count
        end
      end
      reload
      self.stock -= debit
      save
    end
  end
end