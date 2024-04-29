require 'chronicle/etl'
require 'chronicle/models'

module Chronicle
  module Pinboard
    class PinboardTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.source = :pinboard
        r.type = :bookmark
        r.strategy = :api
        r.description = 'a booknark from pinboard'
        r.from_schema = :extraction
        r.to_schema = :chronicle
      end

      def transform(record)
        site = build_site(record.data)
        agent = build_agent(record.extraction.meta[:username])
        id = record.data[:hash]
        end_time = Time.parse(record.data[:time])

        actions = []

        actions << build_bookmark(site:, agent:, id:, end_time:)

        note = record.data[:extended]
        actions << build_comment(site:, agent:, id:, end_time:, note:) if note.size.positive?

        actions.compact
      end

      private

      def build_bookmark(site:, agent:, id:, end_time:)
        Chronicle::Models::BookmarkAction.new do |r|
          r.source = 'pinboard'
          r.source_id = id
          r.end_time = end_time
          r.agent = agent
          r.object = site

          r.dedupe_on = [%i[source source_id type]]
        end
      end

      def build_comment(site:, agent:, id:, note:, end_time:)
        comment = Chronicle::Models::Comment.new do |r|
          r.source = 'pinboard'
          r.source_id = id
          r.text = note
          r.about = [site]
          r.dedupe_on = [%i[source source_id type]]
        end

        Chronicle::Models::CommentAction.new do |r|
          r.source = 'pinboard'
          r.source_id = id
          r.end_time = end_time
          r.agent = agent
          r.result = comment
          r.object = site

          r.dedupe_on = [%i[source source_id type]]
        end
      end

      def build_site(bookmark)
        Chronicle::Models::Thing.new do |r|
          r.name = bookmark[:description]
          r.url = bookmark[:href]
          r.dedupe_on = [[:url]]
          r.keywords = bookmark[:tags].split.map(&:strip)
        end
      end

      def build_agent(username)
        Chronicle::Models::Person.new do |r|
          r.source = 'pinboard'
          r.slug = username
          r.url = "https://pinboard.in/u:#{username}"
          r.dedupe_on = [[:url], %i[source slug type]]
        end
      end
    end
  end
end
