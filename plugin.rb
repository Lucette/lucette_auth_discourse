# name: Lucette authenticator
# about: Allows users to connect using the credentials stored and exposed at Lucette API
# version: 1.0.0
# authors: Christopher Paccard <christopher@paccard.info>

enabled_site_setting :lucette_auth_enabled

require_relative 'lib/omniauth-lucette'

class LucetteAuthenticator < ::Auth::Authenticator
  def name
    'lucette'
  end

  def after_authenticate(auth_options)
    auth_info = auth_options.info
    result = Auth::Result.new

    result.email = auth_info[:email]
    result.name = auth_info[:name]
    result.username = auth_info[:nickname]
    result.user = User.find_by_email(auth_info[:email])

    result.email_valid = true

    result
  end

  def register_middleware(omniauth)
    omniauth.provider self.name
  end

end

auth_provider title: 'Compte Lucette',
              message: 'Se connecter avec son compte Lucette',
              frame_width: 920,
              frame_height: 400,
              authenticator: LucetteAuthenticator.new

register_css <<CSS
 #login-buttons {
     .btn {
         &.lucette {
             background-color: #517693;
        }
    }
}
CSS
