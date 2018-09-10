class WatchlistController < ApplicationController
  include WatchlistHelper

    after_action :set_watchlist, only: [:edit, :update, :destroy]



	def show
		if current_user 
			watchlist
			render :show
    else
        redirect_to new_user_session_path, info: 'Sign in to view profile.'  
    end
  end

  def create
    @watchlist = Watchlist.new(watchlist_params)
    respond_to do |format|
      if current_user
        if @watchlist.save
          format.js
          format.html { redirect_back fallback_location: search_index_url, success: 'Watchlist was successfully created.' }
          
        else
          redirect_to root_path ,danger: "Unsuccessfully , Please Try Again Later"
        end
      end
    end
  end
        
          

          

	def destroy
		if current_user
			set_watchlist
			@watchlist.destroy
			respond_to do |format|
				format.html { redirect_back fallback_location: search_index_url, danger: 'Watchlist was successfully destroyed.' }
				format.json { head :no_content }
				
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
