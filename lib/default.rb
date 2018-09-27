# frozen_string_literal: true

require "babosa"
require "tilt"
require "slim"
require "erubis"

include Nanoc::Helpers::LinkTo
include Nanoc::Helpers::Text
include Nanoc::Helpers::Rendering

ENV['TZ'] = 'UTC'

Tilt.prefer Tilt::KramdownTemplate
Slim::Embedded.options[:markdown] = { auto_ids: false }

Nanoc::Filter.define(:clean_indents) do |content, _params|
	content.gsub(/^\s+$/, "\n").gsub(/^(\t*)(  )+/) { |match| $~[1] + "\t" * ($~.to_a.length - 2) }
end

$posts = {}
def posts(*kinds)
	patterns = "{#{kinds.map(&:to_s).join(",")}}"

	$posts[[kinds, @items.first.class]] ||= @items.find_all("/#{patterns}/*/index.*")
		.sort { |a, b| b[:date] <=> a[:date] }
end

def articles
	posts :articles
end

$year_index = {}
def by_year(posts)
	$year_index[[posts, @items.first.class]] ||= send(posts).group_by { |post| post[:date].year }
end

def u(s)
	URI.escape(s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
end
