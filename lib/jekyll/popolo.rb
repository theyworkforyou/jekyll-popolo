require 'jekyll/popolo/version'
require 'jekyll'
require 'json'

module Jekyll
  module Popolo
    def self.register(popolo_name, popolo_json_string)
      @popolo_files ||= {}
      @popolo_files[popolo_name] = JSON.parse(popolo_json_string)
    end

    def self.process(popolo_name, &block)
      @popolo_processors ||= []
      @popolo_processors << {
        popolo_name: popolo_name,
        block: block,
      }
    end

    def self.generate(site)
      collections = @popolo_processors.reduce({}) do |memo, processor|
        memo.merge(processor[:block].call(site, @popolo_files[processor[:popolo_name]]))
      end
      collections.each do |name, items|
        collection_name = name.to_s
        collection = Jekyll::Collection.new(site, collection_name)
        items.each do |item|
          path = File.join(site.source, "_#{collection_name}", "#{Jekyll::Utils.slugify(item['id'])}.md")
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

Jekyll::Hooks.register :site, :post_read do |site|
  Jekyll::Popolo.generate(site)
end
