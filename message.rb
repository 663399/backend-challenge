class Message
  include DataMapper::Resource

  property :id, Serial
  property :sender, String, required: true
  property :message, Text, required: true
  property :conversation_id, Integer, required: true
  property :created_at, DateTime
  property :updated_at, DateTime
end
