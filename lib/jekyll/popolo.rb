require 'jekyll/popolo/version'
require 'jekyll'
require 'everypolitician/popolo'

module Jekyll
  module Popolo
    class PopoloGenerator < Jekyll::Generator
      def generate(site)
        Jekyll::Popolo.generate(site)
      end
    end

    def self.register(popolo_name, popolo_json_string)
      @popolo_files ||= {}
      @popolo_files[popolo_name] = ::Everypolitician::Popolo.parse(popolo_json_string)
    end

    def self.process(popolo_name)
      @collections ||= {}
      @collections.merge!(yield(@popolo_files[popolo_name]))
    end

    def self.generate(site)
      @collections.each do |name, items|
        collection_name = name.to_s
        collection = Jekyll::Collection.new(site, collection_name)
        items.each do |item|
          path = File.join(site.source, "_#{collection_name}", "#{Jekyll::Utils.slugify(item.id)}.md")
          doc = Document.new(path, collection: collection, site: site)
          doc.merge_data!(item.document)
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
