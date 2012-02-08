# -*- coding: utf-8 -*-

module GoogleAnalytics
  module Mobile
    module Helpers
      class << self
        def prefix
          @prefix ||= '/analytics'
        end
        attr_writer :prefix

        attr_accessor :tracking_id

        def configure
          yield self
        end
      end

      def beacon_uri
        query = Rack::Utils.build_query({
          utmac: Helpers.tracking_id,
          utmn:  rand(0xffffffff),
          utmr:  request.referer,
          utmp:  request.fullpath,
          guid:  'ON',
        })
        "#{Helpers.prefix}/?#{query}"
      end

      def beacon_tag
        %{<img src="#{beacon_uri}" />}
      end
    end
  end
end

