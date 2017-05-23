require 'json'
require 'rest-client'

module LitaWhatsForLunch
  module Restaurants


    def pick_restaurant(response)
      api_root = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      unless api_key
        response.reply("Please provide me with the Google API key of your choosing")
        return
      end
      unless location
        response.reply("Please provide me with a location to center my search around")
        return
      end

      resp = RestClient.get("#{api_root}?location=#{location}&radius=500&type=restaurant&key=#{api_key}")

      # FIXME handle bad response
      restaurants = []
      json = JSON.parse(resp.body)
      while json['next_page_token']
        json['results'].each {|result|
          restaurants << json['name'] }
        resp = RestClient.get("#{api_root}?pagetoken=#{json['next_page_token']}&key=#{api_key}")
      end

      response.reply("You are going to #{restaurants.sample}")
    end


    def api_key
      @api_key ||= redis.get('api-key')
    end

    def location
      @location ||= redis.get('location-coordinates')
    end

  end
end
