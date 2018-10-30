class LinebotController < ApplicationController
  require 'line/bot'

  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)

    events.each { |event|
      case event.type
        when 'text'
          case event.message['text']
            when '猫', 'ねこ', 'ネコ'
              message = {
                type: 'text',
                text: 'にゃーん'
              }
             when '犬', 'いぬ', 'イヌ'
              message = {
                type: 'text',
                text: 'わんわん'
              }
            else
              message = {
              type: 'text',
              text: event.message['text']
              }
          end
        else
          message = {
            type: 'text',
            text: 'テキストでメッセージを送ってね'
          }
        end
      client.reply_message(event['replyToken'], message)
    }
    head :ok
  end
end
