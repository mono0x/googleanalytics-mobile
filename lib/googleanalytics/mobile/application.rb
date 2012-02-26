
require 'digest/md5'
require 'open-uri'
require 'rack/utils'
require 'timeout'
require 'time'
require 'sinatra/base'

module GoogleAnalytics
  module Mobile
    class Application < Sinatra::Base
      VERSION = '4.4sp'
      COOKIE_NAME = '__utmmobile'
      UTM_GIF_LOCATION = 'http://www.google-analytics.com/__utm.gif'
      GIF_DATA = [
        0x47, 0x49, 0x46, 0x38, 0x39, 0x61,
        0x01, 0x00, 0x01, 0x00, 0x80, 0xff,
        0x00, 0xff, 0xff, 0xff, 0x00, 0x00,
        0x00, 0x2c, 0x00, 0x00, 0x00, 0x00,
        0x01, 0x00, 0x01, 0x00, 0x00, 0x02,
        0x02, 0x44, 0x01, 0x00, 0x3b
      ].pack('C35')

      helpers do
        def send_request_to_google_analytics
          begin
            timeout 3 do
              open(utm_url, {
                'Accept-Language' => request.env['HTTP_ACCEPT_LANGUAGE'],
                'User-Agent' => request.user_agent,
              }).read
            end
          rescue TimeoutError
          rescue OpenURI::HTTPError
          end
        end

        def visitor_id
          cookie = request.cookies[COOKIE_NAME]
          return cookie if cookie

          account = params[:utmac]
          guid =
            request.env['HTTP_X_DCMGUID'] ||
            request.env['HTTP_X_UP_SUBNO'] ||
            request.env['HTTP_X_JPHONE_UID'] ||
            request.env['HTTP_X_EM_UID']
          if guid
            message = "#{guid}#{account}"
          else
            message = "#{request.user_agent}#{rand 0xffffffff}"
          end
          "0x#{Digest::MD5.hexdigest(message)[0, 16]}"
        end

        def utm_url
          query = Rack::Utils.build_query({
            utmwv:  VERSION,
            utmn:   rand(0xffffffff),
            utmhn:  request.env['SERVER_NAME'],
            utmr:   params[:utmr],
            utmp:   params[:utmp],
            utmac:  params[:utmac],
            utmcc:  '__utma=999.999.999.999.999.1;',
            utmvid: visitor_id,
            utmip:  request.ip.sub(/\d{1,3}\z/, '0'),
          })
          "#{UTM_GIF_LOCATION}?#{query}"
        end
      end

      get '/' do
        send_request_to_google_analytics

        content_type 'image/gif'
        response.set_cookie COOKIE_NAME, {
          value:   visitor_id,
          path:    '/',
          expires: Time.now + 2 * 365 * 24 * 60 * 60,
        }
        expires -24 * 60 * 60, :private, :proxy_revalidate, no_cache: 'Set-Cookie'
        GIF_DATA
      end
    end
  end
end

