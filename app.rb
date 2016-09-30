require 'sinatra'
require 'line/bot'
set :bind, '0.0.0.0'

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = '12b9b5e209d8e7845b51b88556d07cb8'
    config.channel_token =  'Bh4pvhu8WAM6JWFPm8CdXBcMyEanmVZq48Y73Tvb/sT5xS43UCFNrbcC404oirSa4t+pJ1cO3yJkjcz7jcm/zpFuyqHUi1+yOsNckwLlz2J4UK94+3kcdEU2wZFCZ4V9TSg+DIaqQD8WApT7bYsSOgdB04t89/1O/w1cDnyilFU='
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

  events = client.parse_events_from(body)
  p events
  events.each { |event|
    case event
    when Line::Bot::Event::Beacon
      message = {
        type: 'text',
        text: 'おかえり！'
      }
      client.reply_message(event['replyToken'], message)
    end
  }
end
