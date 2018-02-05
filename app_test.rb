ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
load 'app.rb'

class ElevenTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Eleven
  end

  def test_messages
    post '/messages', sender: 'eleven', message: 'mouth breather', conversation_id: 123

    assert 201, last_response.status
    assert_equal 'eleven', JSON.parse(last_response.body)['sender']
    assert_equal 'mouth breather', JSON.parse(last_response.body)['message']
    assert_equal 123, JSON.parse(last_response.body)['conversation_id']
  end

  def test_messages_without_sender
    post '/messages', message: 'who dis', conversation_id: 123

    assert 500, last_response.status
    assert_equal 'Sender must not be blank', JSON.parse(last_response.body).first
  end

  def test_messages_without_message
    post '/messages', sender: 'the upside down', conversation_id: 123

    assert 500, last_response.status
    assert_equal 'Message must not be blank', JSON.parse(last_response.body).first
  end

  def test_messages_without_conversation_id
    post '/messages', sender: 'barb', message: 'i\'m chill'

    assert 500, last_response.status
    assert_equal 'Conversation must not be blank', JSON.parse(last_response.body).first
  end

  def test_messages_with_invalid_conversation_id
    post '/messages', sender: 'barb', message: 'i\'m chill', conversation_id: 'invalid'

    assert 500, last_response.status
    assert_equal 'Conversation must be an integer', JSON.parse(last_response.body).first
  end

  def test_conversation_with_valid_id
    conversation_id = 1234
    Message.create(sender: 'dustin', message: 'she\'s our friend and she\'s crazy', conversation_id: conversation_id)
    Message.create(sender: 'dustin', message: 'i am on a curiosity voyage and i need my paddles to travel', conversation_id: conversation_id)
    get "/conversation/#{conversation_id}"

    assert 200, last_response.status
    assert_equal '1234', JSON.parse(last_response.body)['id']
    assert_equal 2,  JSON.parse(last_response.body)['messages'].length
  end

  def test_conversation_with_alphanumeric_id
    get '/conversation/1a2b3c'

    assert_equal 'Conversation Not Found', last_response.body
  end

  def test_conversation_with_bad_url
    get '/conversation/http://stranger-danger.com'

    assert 404, last_response.status
    assert_equal 'Not Found', last_response.body
  end
end
