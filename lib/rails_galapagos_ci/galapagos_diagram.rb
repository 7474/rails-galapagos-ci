require "rails_erd/config"

# XXX RailsERD::Diagram::Graphviz がメソッド直撃で参照しているので
# 頑張るなら RailsERD::Diagram::Graphviz 自体をフォークして、設定値としてフォントを受け取った方がよさそう
# XXX Webページに埋めるSVG目的だと、IPAフォントはあまり普及していない気がする
module RailsERD
  class Config
    def self.font_names_based_on_os
      { normal: "IPA Pゴシック",
        bold:   "IPA Pゴシック",
        italic: "IPA Pゴシック" }
    end
  end
end

require "rails_erd/diagram/graphviz"

module RailsGalapagosCi
  class GarapagosDiagram < RailsERD::Diagram::Graphviz

    def initialize(domain, options = {})
      super(domain, options)
      @options = RailsGalapagosCi.options.merge(@options).merge(options)
      @domain.inject_comment()
    end

    # XXX スーパークラスでのコールバックの登録が動作しない
    # そもそも、なぜ単純な protected メソッドにしなかったのかが不明。
    setup do
      self.graph = GraphViz.digraph(domain.name)

      # Set all default attributes.
      GRAPH_ATTRIBUTES.each { |attribute, value| graph[attribute] = value }
      NODE_ATTRIBUTES.each  { |attribute, value| graph.node[attribute] = value }
      EDGE_ATTRIBUTES.each  { |attribute, value| graph.edge[attribute] = value }

      # Switch rank direction if we're creating a vertically oriented graph.
      graph[:rankdir] = :TB if options.orientation == :vertical

      # Title of the graph itself.
      graph[:label] = "#{title}\\n\\n" if title

      # Setup notation options.
      extend self.class.const_get(options.notation.to_s.capitalize.to_sym)
    end

    save do
      raise "Saving diagram failed!\nOutput directory '#{File.dirname(filename)}' does not exist." unless File.directory?(File.dirname(filename))

      begin
        # GraphViz doesn't like spaces in the filename
        graph.output(filetype => filename.gsub(/\s/,"_"))
        filename
      rescue RuntimeError => e
        raise "Saving diagram failed!\nGraphviz produced errors. Verify it " +
                  "has support for filetype=#{options.filetype}, or use " +
                  "filetype=dot.\nOriginal error: #{e.message.split("\n").last}"
      rescue StandardError => e
        raise "Saving diagram failed!\nVerify that Graphviz is installed " +
                  "and in your path, or use filetype=dot."
      end
    end

    each_entity do |entity, attributes|
      draw_node entity.name, entity_options(entity, attributes)
    end

    each_specialization do |specialization|
      from, to = specialization.generalized, specialization.specialized
      draw_edge from.name, to.name, specialization_options(specialization)
    end

    each_relationship do |relationship|
      from, to = relationship.source, relationship.destination
      unless draw_edge from.name, to.name, relationship_options(relationship)
        from.children.each do |child|
          draw_edge child.name, to.name, relationship_options(relationship)
        end
        to.children.each do |child|
          draw_edge from.name, child.name, relationship_options(relationship)
        end
      end
    end

    # XXX テンプレートのパス解決がイケてない
    def entity_options(entity, attributes)
      label = options[:markup] ? "<#{read_template(:html).result(binding)}>" : "#{read_template(:record).result(binding)}"
      entity_style(entity, attributes).merge :label => label
    end
    def read_template(type)
      if options[:rogical_name]
        ERB.new(File.read(File.expand_path("templates/rogical/#{NODE_LABEL_TEMPLATES[type]}", File.dirname(__FILE__))), nil, "<>")
      else
        ERB.new(File.read(File.expand_path("templates/#{NODE_LABEL_TEMPLATES[type]}", File.dirname(__FILE__))), nil, "<>")
      end
    end
  end
end

module RailsGalapagosCi
  module Commentable
    def db_comment=(db_comment)
      @db_comment = db_comment
      return @db_comment unless @db_comment

      # XXX いい感じに区切る(空白文字だと英語圏に対応できないので、タブと改行にした方がいい？)
      @r_name = /[^\s]*/.match(db_comment)[0]

      m = /[\s]+(.*)/.match(db_comment)
      if m
        @remark = m[0]
      end
    end

    def db_comment
      @db_comment
    end

    def r_name
      @r_name ? @r_name: name
    end

    def remark
      @remark
    end
  end
end

module RailsERD
  class Domain
    # 全Entityに MigrationComments のコメントを注入する。
    def inject_comment
      entities.each do |entity|
        entity.inject_comment
      end
    end
  end
end

module RailsERD
  class Domain
    class Entity
      include RailsGalapagosCi::Commentable

      inspection_attributes :name, :type, :r_name, :remark

      # 自身及び所有する全Attributeに MigrationComments のコメントを注入する。
      def inject_comment
        self.db_comment = ActiveRecord::Base.connection.retrieve_table_comment name.tableize
        db_column_comments = ActiveRecord::Base.connection.retrieve_column_comments(name.tableize)
        attributes.each do |attribute|
          attribute.db_comment = db_column_comments[attribute.name.to_sym]
        end
      end

      # Override: 必須の下付き*を通常の*に変更した。
      def type_description
        type.to_s.tap do |desc|
          desc << " #{limit_description}" if limit_description
          desc << "*" if mandatory? && !primary_key?
          desc << " U" if unique? && !primary_key? && !foreign_key? # Add U if unique but non-key
          desc << " PK" if primary_key?
          desc << " FK" if foreign_key?
        end
      end
    end
  end
end

module RailsERD
  class Domain
    class Attribute
      include RailsGalapagosCi::Commentable
    end
  end
end
