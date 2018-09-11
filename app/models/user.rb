class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

         has_many :watchlists,dependent: :destroy
         mount_uploader :avatar, AvatarUploader


  def full_name
    first_name + " " + last_name
    
  end
end
