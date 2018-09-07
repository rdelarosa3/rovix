class CreateWatchlist < ActiveRecord::Migration[5.2]
  def change
    create_table :watchlists do |t|
     
      t.string :name    
      t.timestamps
      
    end
    add_reference :watchlists, :following
    add_reference :watchlists, :user, index: true
  
  end
end
      
      
