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
      @message = event.message['text']
      case event.type
        when 'text'
          if Reply.exists?(word: @message)
            @for_reply = Reply.find_by(word: @message)
              message = {
                type: 'text',
                text: @for_reply.reply_message
              }
            else
              message = {
              type: 'text',
              text: @message
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
