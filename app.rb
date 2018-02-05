require 'sinatra/json'
require 'data_mapper'
load 'message.rb'

DataMapper.setup :default, "sqlite://#{Dir.pwd}/database.db"
DataMapper.finalize
DataMapper.auto_migrate!

class Eleven < Sinatra::Base
  # Creates a new message
  post '/messages' do
    message = Message.new(
      sender: Rack::Utils.escape_html(params[:sender]),
      message: Rack::Utils.escape_html(params[:message]),
      conversation_id: Rack::Utils.escape_html(params[:conversation_id])
    )

    if message.save
      status 201
      json message
    else
      status 500
      json message.errors.full_messages
    end
  end

  # Returns a conversation by id
  get '/conversation/:id' do
    id = Rack::Utils.escape_html(params[:id])

    # 'Conversation' should probably have its own table in the db.
    # As conversations get longer, it will be costly to query all the
    # messages that share the same id and then order them.
    messages = Message.all(conversation_id: id, order: [ :created_at.asc ])

    if messages.any?
      JSON.generate({ id: id, messages: messages })
    else
      'Conversation Not Found'
    end
  end

  # Fallback endpoint
  get '/*' do
    status 404
    'Not Found'
  end
end
