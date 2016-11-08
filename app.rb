require 'sinatra'
require 'line/bot'
set :bind, '0.0.0.0'

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"] 
    config.channel_token  = ENV["LINE_CHANNEL_TOKEN"]
  }
end

get '/' do
  'HerokuでSinatraを使ってHello world!'
end

post '/callback' do  # botの設定時にWeb Hook URLに登録したパス。
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature) # signatureの確認
    error 400 do 'Bad Request' end
  end

  redis = Redis.new(ENV["REDIS_URL"])
  logger.error redis
  events = client.parse_events_from(body)
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        message = {
          type: 'text',
          #text: event.message['text']
          text: event.message['from']
        }
        client.reply_message(event['replyToken'], message)
      end
    when Line::Bot::Event::Beacon
      message = {
        type: 'text',
        text: 'やぁ。げっしーだお！'
      }
      client.reply_message(event['replyToken'], message)
    end
  }
end
