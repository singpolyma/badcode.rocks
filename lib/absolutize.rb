# frozen_string_literal: true

require "nokogiri"
require "uri"

class AbsolutizeFilter < Nanoc::Filter
	identifier :absolutize

	def run(content, _params)
		doc = Nokogiri::HTML::DocumentFragment.parse(content)
		doc.traverse do |node|
			["src", "href", "data"].each do |attr|
				next unless node.attributes[attr]
				node.attributes[attr].value = absolutize(node.attributes[attr].to_s)
			end
		end

		doc.to_xhtml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XHTML)
	end

	def absolutize(ref)
		return ref if ref.to_s =~ /\A\w+:|\A\//
		"#{@item.path}#{ref}"
	end
end
