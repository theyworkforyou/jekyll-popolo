require 'jekyll/popolo/version'
require 'jekyll'
require 'json'
require 'singleton'

module Jekyll
  module Popolo
    def self.method_missing(name, *args, &block)
      Manager.instance.__send__(name, *args, &block)
    end

    def self.respond_to_missing?(name, include_private = false)
      Manager.instance.respond_to?(name)
    end

    class Manager
      include Singleton

      attr_reader :files
      attr_reader :processors
      attr_reader :site

      def initialize
        @files = {}
        @processors = []
      end

      def register_popolo_file(popolo_name, popolo_json_string)
        files[popolo_name] = JSON.parse(popolo_json_string)
      end

      def process(&block)
        processors << block
      end

      def generate(site)
        @site = site
        processors.each { |processor| processor.call(site, self) }
      end

      def create_jekyll_collections(collections)
        collections.each do |name, items|
          collection_name = name.to_s
          collection = Jekyll::Collection.new(site, collection_name)
          items.each do |item|
            path = File.join(
              site.source,
              "_#{collection_name}",
              "#{Jekyll::Utils.slugify(item['id'])}.md"
            )
            doc = Document.new(path, collection: collection, site: site)
            doc.merge_data!(item)
            if site.layouts.key?(collection_name)
              doc.merge_data!('layout' => collection_name)
            end
            collection.docs << doc
          end
          site.collections[collection_name] = collection
        end
      end
    end
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  Jekyll::Popolo.generate(site)
end
