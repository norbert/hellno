require 'time'

require 'faraday'
require 'faraday_middleware'

module HellNo
  BASE_URL = "https://getamen.com/"
  FEED_PATH = "/amen.json"
  USER_PATH = "/users/%d.json"
  USER_FEED_PATH = "/users/%d/amen.json"
  AMEN_PATH = "/amen/%d.json"

  #USER_AGENT = "Hell No/#{HellNo::VERSION}"
  USER_AGENT = "Amen/1.5.2 (iPhone; CPU OS 5_1_1)"

  class Error < StandardError
  end
  class AuthenticationError < Error
  end

  class Client
    attr_reader :auth_token

    def initialize(auth_token = nil)
      auth_token ||= ENV['AMEN_AUTH_TOKEN']
      @auth_token = auth_token
    end

    def self.connection(auth_token)
      Faraday.new(BASE_URL) do |conn|
        conn.request :json # FIXME
        conn.response :json

        conn.headers['User-Agent'] = USER_AGENT
        conn.params[:auth_token] = auth_token

        conn.adapter Faraday.default_adapter
      end
    end

    def connection
      @connection ||= self.class.connection(auth_token)
    end

    def feed(path = nil, last_amen_id = nil)
      path ||= feed_path

      data = load_data do |req|
        req.url(path)

        if !last_amen_id.nil? # FIXME
          req.params[:last_amen_id] = Integer(last_amen_id).to_s
        end
      end

      data.map do |amen_data|
        Amen.new(amen_data)
      end
    end

    def feed_path
      FEED_PATH
    end

    def user(id)
      load_instance(User, user_path(id))
    end

    def user_path(id)
      USER_PATH % id
    end

    def amen(id)
      load_instance(Amen, amen_path(id))
    end

    def amen_path(id)
      AMEN_PATH % id
    end

    private
    def load_data
      response = connection.get do |req|
        yield req
      end

      data = response.body

      if data == ["error", ""] # FIXME
        raise AuthenticationError
      end

      data
    end

    def load_instance(klass, path)
      data = load_data do |req|
        req.url(path)
      end

      if !data.nil? && data != [] # FIXME
        klass.new(data)
      end
    end
  end

  class Resource
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def id
      data['id']
    end

    def url
      data['url']
    end

    def created_at
      if time_data = data['created_at']
        Time.parse(time_data)
      end
    end
  end

  class Amen < Resource
  end

  class User < Resource
    def username
      data['username']
    end

    def feed_path
      USER_FEED_PATH % id
    end

    def recent_amen
      data['recent_amen'].map do |amen_data|
        Amen.new(amen_data)
      end
    end
  end
end
