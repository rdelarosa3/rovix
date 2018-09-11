class User < ApplicationRecord
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable,:omniauthable,omniauth_providers: %i[facebook]# ,omniauth_providers: [:google_oauth2]

         has_many :watchlists,dependent: :destroy
         mount_uploader :avatar, AvatarUploader


    def full_name
      first_name + " " + last_name
    end

#     def self.from_omniauth(auth)
#       where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
#         user.email = auth.info.email
#         user.password = Devise.friendly_token[0,20]
#         user.name = auth.info.name   # assuming the user model has a name
#         user.image = auth.info.image # assuming the user model has an image
#         # If you are using confirmable and the provider(s) you use validate emails, 
#         # uncomment the line below to skip the confirmation emails.
#         # user.skip_confirmation!
#       end
#     end   
      
    # def self.from_omniauth(access_token)
    #   data = access_token.info
    #   user = User.where(email: data['email']).first

    #   # Uncomment the section below if you want users to be created if they don't exist
    #     unless user
    #         user = User.create(
    #           first_name: data['first_name'],
    #           last_name: data['last_name'],
    #           email: data['email'],
    #           password: Devise.friendly_token[0,20]
    #         )
    #     end
        
    #   user
    # end

  def self.new_with_session(params, session)
  super.tap do |user|
    if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
      user.email = data["email"] if user.email.blank?
      end
    end 
  end


  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.first_name = auth.info.name   # assuming the user model has a name
      user.last_name = ""   # assuming the user model has a name
      user.avatar = auth.info.image # assuming the user model has an image
    end
  end

  
end
