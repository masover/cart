class Item
  include Base
  
  property :name, String, :required => true
  property :description, Text
  property :stock, Integer, :default => 0
  
  has_descendants :item_transactions
  
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