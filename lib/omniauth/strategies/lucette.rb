require 'omniauth'
require 'net/http'
require 'json'

module OmniAuth
  module Strategies
    class Lucette
      include OmniAuth::Strategy

      uid {
        @authentication_body['_id']
      }
      info {
        {
          name: "#{@authentication_body['firstname']} #{@authentication_body['lastname']}",
          email: @authentication_body['email'],
          nickname: @authentication_body['email'],
          first_name: @authentication_body['firstname'],
          last_name: @authentication_body['lastname']
        }
      }
      extra {
        { raw_info: @authentication_body }
      }

      def request_phase
        @url = callback_path
        @css = File.read(File.expand_path("../../../omniauth-lucette/css/form.css", __FILE__))
        template = ERB.new(File.read(File.expand_path("../../../omniauth-lucette/views/form.html.erb", __FILE__))).result(binding)

        Rack::Response.new(template)
      end

      def callback_phase
        return fail!(:missing_credentials) if !authentication_response
        return fail!(:invalid_credentials) if authentication_response.code.to_i != 200

        @authentication_body = JSON.parse(@authentication_response.body)
        super
      end

      private
      def authentication_response
        unless @authentication_response
          email = request['email']
          password = request['password']
          return unless email && password

          uri = URI(SiteSetting.lucette_auth_endpoint)
          http = Net::HTTP.new(uri.host, uri.port)
          if uri.scheme == 'https'
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end

          req = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')

          req.body = {
            email: request['email'],
            password: request['password']
          }.to_json

          @authentication_response = http.request(req)
        end

        @authentication_response
      end

    end
  end
end
