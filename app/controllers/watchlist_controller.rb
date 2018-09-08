class WatchlistController < ApplicationController
    after_action :set_watchlist, only: [:edit, :update, :destroy]


  def create
    @watchlist = Watchlist.new(watchlist_params)
     
    respond_to do |format|
      if current_user
        if @watchlist.save
          
          format.html { redirect_to search_index_url, success: 'Watchlist was successfully created.' }
        else
          redirect_to root_path ,danger: "Unsuccessfully , Please Try Again Later"
        end
        
      end
    end
  end
    


	private
	def watchlist_params
      params.permit(:name,:user_id,:following_id,:id)
    end

	def set_watchlist
		@watchlist = Watchlist.find_by(user_id: current_user.id, name: params[:name])
	end
end
