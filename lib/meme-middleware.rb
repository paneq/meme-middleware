# encoding: utf-8

require "meme-middleware/version"
require "json"
require "uri"
require 'net/http'

module Meme
  module Middleware

    class Base

      MEMES = {
        dos_equis:     { image: 2485,     generator: 74,  regexp: /(I don\'?t always )(.+) (‡)?(but when I do )(.+)[^ a-zA-Z]/i },
        y_u_no?:       { image: 166088,   generator: 2,   regexp: /[^ a-zA-Z](.*)(Y U NO )(‡)?(.+)[^ a-zA-Z]/i  },
        bear_grylls:   { image: 89714,    generator: 92,  regexp: /[^ a-zA-Z](.*)(‡)?( better drink my own piss)[^ a-zA-Z]/}
        #fry:          { image: 84688,    generator: 305  },
      }

      def initialize(app)
        self.app  = app
      end

      def call(env)
        status, headers, response = @app.call(env)
        if headers["Content-Type"].include? "text/html"
          [status, headers, memeized_body(response)]
        else
          [status, headers, response]
        end
      end

      def memeized_body(response)
        if response.respond_to?(:body)
          MEMES.each do |key, mem|
            response.body.gsub!(mem[:regexp]) do |match|
              elements = [$1, $2, $3, $4, $5]
              mark = elements.find_index(nil) # find ‡ that does not occur :)
              top = elements[0..mark].join
              bottom = elements[mark..-1].join

              img_path = create_image(mem[:generator], mem[:image], top, bottom)
              html = <<-HTML
<img src="#{img_path}"/>
HTML
            end
          end
          response
        else
          raise NotImplementedError # response.body is Rails specific, put general rack code here. Response responds to :each.
        end
      end

      def create_image(generator, image, top, bottom)
        puts [generator, image, top, bottom].inspect
        return "example.org"
        uri = URI('http://version1.api.memegenerator.net/Instance_Create')
        params = {
          :username => 'drug-bot',
          :password => 'drug-bot',
          :languageCode => 'en',
          :generatorID => generator,
          :imageID => image,
          :text0 => top,
          :text1 => bottom
        }
        uri.query = URI.encode_www_form(params)
        response = Net::HTTP.get_response(uri)
        meme = JSON.parse(response.body)
        url = "http://version1.api.memegenerator.net#{meme['result']['instanceImageUrl']}"
      end

      private

      attr_accessor :app
    end

    class Memory < Base
      def initialize(app)
        super
        @cache = {}
      end

      def create_image(*params)
        @cache[params] ||= super
      end
    end

    class ActiveRecord < Base
      def initialize(app)
        raise NotImplementedError
      end
    end

    class Mongo < Base
      def initialize(app)
        raise NotImplementedError
      end
    end
  end
end

body = <<-BODY
  Lorem ipsul dolet sit amet
  asdasd y u no kill me ?? ddd
  y u no kill me
  asdasd
  blahbasd asdasd asd! created new ruby library, better drink my own piss? asdasd asdasd
BODY


inner = Proc.new{|env| [200, {"Content-Type" => "text/html"}, Struct.new(:body).new(body)] }
m = Meme::Middleware::Memory.new(inner)
m.call(env = {})[2]
m.call(env = {})[2]
puts m.call(env = {})[2].inspect
