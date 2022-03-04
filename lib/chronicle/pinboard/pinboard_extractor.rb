require 'chronicle/etl'
require 'faraday'

module Chronicle
  module Pinboard 
    class PinboardExtractor < Chronicle::ETL::Extractor
      register_connector do |r|
        r.provider = 'pinboard'
        r.description = 'bookmarks'
      end

      setting :access_token, required: true

      def prepare
        @bookmarks = load_bookmarks
        @username = @config.access_token.split(":").first
      end

      def extract
        @bookmarks.each do |bookmark|
          yield Chronicle::ETL::Extraction.new(data: bookmark, meta: { username: @username })
        end
      end

      def results_count
        @bookmarks.count
      end

      private

      def load_bookmarks
        params = {
          auth_token: @config.access_token,
          format: 'json',
          meta: true,
        }
        params[:fromdt] = @config.since.utc.iso8601 if @config.since

        conn = Faraday.new(
          url: 'https://api.pinboard.in/',
          params: params
        )

        response = conn.get('/v1/posts/all')
        bookmarks = JSON.parse(response.body, { symbolize_names: true })
        bookmarks = bookmarks.keep_if { |bookmark| Time.parse(bookmark[:time]) < @config.until } if @config.until
        bookmarks
      end
    end
  end
end
