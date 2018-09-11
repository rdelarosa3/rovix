class Watchlist < ApplicationRecord
    belongs_to :user
<<<<<<< HEAD
     validates :name, uniqueness: true
=======

    validates :name, uniqueness: true
>>>>>>> search_css
end
