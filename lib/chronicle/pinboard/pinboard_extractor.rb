require 'chronicle/etl'
require 'faraday'

module Chronicle
  module Pinboard
    class PinboardExtractor < Chronicle::ETL::Extractor
      register_connector do |r|
        r.source = :pinboard
        r.type = :bookmark
        r.strategy = :api
        r.description = 'a bookmark from pinboard'
      end

      setting :access_token, required: true

      def prepare
        raise(Chronicle::ETL::ExtractionError, 'Access token is missing') if @config.access_token.empty?

        @bookmarks = load_bookmarks
        @username = @config.access_token.split(':').first
      end

      def extract
        @bookmarks.each do |bookmark|
          yield build_extraction(data: bookmark, meta: { username: @username })
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
          meta: true
        }
        params[:fromdt] = @config.since.utc.iso8601 if @config.since

        conn = Faraday.new(
          url: 'https://api.pinboard.in/',
          params:
        )

        response = conn.get('/v1/posts/all')
        bookmarks = JSON.parse(response.body, { symbolize_names: true })
        bookmarks = bookmarks.keep_if { |bookmark| Time.parse(bookmark[:time]) < @config.until } if @config.until
        bookmarks = bookmarks.first(@config.limit) if @config.limit
        bookmarks
      end
    end
  end
end
