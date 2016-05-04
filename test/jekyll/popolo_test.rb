require 'test_helper'

class Jekyll::PopoloTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Jekyll::Popolo::VERSION
  end

  def site
    @site ||= Jekyll::Site.new(Jekyll.configuration)
  end

  def test_creating_mps_collection
    Jekyll::Popolo.register :senate, File.read('test/fixtures/au-senate.json')
    Jekyll::Popolo.process(:senate) { |p| { mps: p.persons } }
    Jekyll::Popolo.generate(site)
    assert site.collections.key?('mps'), "Expected site to have an mps collection"
    assert_equal 475, site.collections['mps'].docs.size
  end
end
