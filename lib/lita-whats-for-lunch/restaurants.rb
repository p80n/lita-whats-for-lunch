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

      restaurants = []
      if r = Lita.redis.get('restaurants')
        restaurants = JSON::parse(r)
      else
        resp = RestClient.get("#{api_root}?location=#{location}&radius=500&type=restaurant&key=#{api_key}")

        # FIXME handle bad response
        json = JSON.parse(resp.body)

        while json['next_page_token']
          json['results'].each {|result|
            puts "Adding #{result['name']}"
            restaurants << result['name'] }
          puts "Requesting next page of restaurants: #{api_root}?pagetoken=#{json['next_page_token']}&key=#{api_key}"
          sleep 5
          resp = RestClient.get("#{api_root}?pagetoken=#{json['next_page_token']}&key=#{api_key}")

          if resp.code == 200
            json = JSON.parse(resp.body)
          else
            json = {}
          end
        end
        puts "Caching restaurant list"
        Lita.redis.set('restaurants', restaurants.to_json)
        Lita.redis.expire('restaurants', 24 * 3600 * 7)
      end

      response.reply("You are going to: #{restaurants.sample}")
    end


    def api_key
      @api_key ||= Lita.redis.get('api-key')
    end

    def location
      @location ||= Lita.redis.get('location-coordinates')
    end

  end
end
