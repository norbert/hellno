require 'test_helper'

class ClientTest < Test::Unit::TestCase
  def test_should_use_env_auth_token_by_default
    old_env_auth_token = ENV['AMEN_AUTH_TOKEN']
    ENV['AMEN_AUTH_TOKEN'] = 'test'
    @client = HellNo::Client.new
    assert_equal 'test', @client.auth_token
  ensure
    ENV['AMEN_AUTH_TOKEN'] = old_env_auth_token
  end

  def test_should_build_connection_using_auth_token
    @connection = HellNo::Client.connection('test')
    assert_equal HellNo::USER_AGENT, @connection.headers['User-Agent']
    assert_equal 'test', @connection.params[:auth_token]
  end

  def test_should_assign_connection_using_auth_token
    @client = HellNo::Client.new('test')
    @connection = mock('connection')
    HellNo::Client.expects(:connection).with('test').returns(@connection)
    assert_equal @connection, @client.connection
  end

  def test_should_load_user_by_id
    @client = HellNo::Client.new('test')
    id = 65368
    data = { id: id, username: 'norbertc', created_at: '2012-08-22T12:14:55Z', recent_amen: [] }
    stub_request(:get, "https://getamen.com#{@client.user_path(id)}").
      with(query: { auth_token: 'test' }).
      to_return(status: 200, body: data.to_json)
    @user = @client.user(id)
    assert_equal id, @user.id
    assert_equal 'norbertc', @user.username
    assert_equal Time.utc(2012, 8, 22, 12, 14, 55), @user.created_at
    assert_equal [], @user.recent_amen
  end
end
