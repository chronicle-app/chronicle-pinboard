require 'chronicle/etl'

module Chronicle
  module Pinboard
    class PinboardTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.provider = 'pinboard'
        r.description = 'bookmark from pinboard'
      end

      def transform
        @bookmark = @extraction.data
        build_liked
      end

      def timestamp
        Time.parse(@bookmark[:time])
      end

      def id
        @bookmark[:hash]
      end

      private

      def build_liked
        record = ::Chronicle::ETL::Models::Activity.new
        record.end_at = timestamp
        record.verb = 'liked'
        record.provider_id = id
        record.provider = 'pinboard'
        record.dedupe_on = [[:provider, :verb, :provider_id]]

        record.involved = build_bookmark
        record.actor = build_actor

        record
      end

      def build_bookmark
        record = ::Chronicle::ETL::Models::Entity.new
        record.title = @bookmark[:description]
        record.provider_url = @bookmark[:href]
        record.dedupe_on << [:provider_url]

        record.abouts = build_tags

        record.aboutables = build_note
        record
      end

      def build_note
        note = @bookmark[:extended]
        return unless note.size.positive?

        record = ::Chronicle::ETL::Models::Entity.new
        record.provider_id = id
        record.represents = "thought"
        record.body = note
        record.provider = "pinboard"
        record.dedupe_on << [:represents, :provider, :provider_id]

        involvement = ::Chronicle::ETL::Models::Activity.new
        involvement.end_at = timestamp
        involvement.verb = 'noted'
        involvement.provider_id = id
        involvement.provider = 'pinboard'
        involvement.dedupe_on << [:provider, :verb, :provider_id]
        involvement.actor = build_actor

        record.involvements = [involvement]

        record
      end

      def build_tags
        @bookmark[:tags].split(" ").map do |tag|
          record = ::Chronicle::ETL::Models::Entity.new
          record.represents = 'topic'
          record.provider = 'pinboard'
          record.slug = tag.downcase
          record.dedupe_on << [:provider, :slug, :represents]
          record
        end
      end

      def build_actor
        record = ::Chronicle::ETL::Models::Entity.new
        record.represents = 'identity'
        record.slug = @extraction.meta[:username] 
        record.provider = 'pinboard'
        record.provider_url = "https://pinboard.in/u:#{record.slug}"
        record.dedupe_on << [:provider_url]
        record.dedupe_on << [:provider, :represents, :slug]
        record
      end
    end
  end
end
