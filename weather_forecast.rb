#!/usr/bin/env ruby
require 'telegram/bot'
require 'uri'
require 'net/http'
require 'rexml/document'
require 'byebug'

TOKEN = 'YOUR_TELEGRAM_BOT_API_TOKEN'

CLOUDINESS = %w(Ясно Малооблачно Облачно Пасмурно).freeze

# city = STDIN.gets.chomp.to_i

uri = URI.parse("https://xml.meteoservice.ru/export/gismeteo/point/294.xml")

response = Net::HTTP.get_response(uri)

doc = REXML::Document.new(response.body)

city_name = URI.unescape(doc.root.elements['REPORT/TOWN'].attributes['sname'])

forecast = doc.root.elements['REPORT/TOWN/FORECAST']

  min_temp = forecast.elements['TEMPERATURE'].attributes['min']
  max_temp = forecast.elements['TEMPERATURE'].attributes['max']
  max_wind = forecast.elements['WIND'].attributes['max']

clouds_index = forecast.elements['PHENOMENA'].attributes['cloudiness'].to_i
clouds = CLOUDINESS[clouds_index]

text_answer = city_name  + " #{min_temp} до #{max_temp} " +clouds

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    case message.text
      when '/start'
        bot.api.send_message(chat_id: message.chat.id,
          text: "Hello, #{message.from.first_name} you want to know weather in Warszawa?")
      when '/c'
        # byebug
        bot.api.send_message(chat_id: message.chat.id,
          text: "Temperature, #{message.from.first_name} #{text_answer}")
      when '/end'
        bot.api.send_message(chat_id: message.chat.id,
          text: "Bye, #{message.from.first_name}")
    end
  end
end
