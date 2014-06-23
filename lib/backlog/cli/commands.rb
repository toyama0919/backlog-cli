#!/usr/bin/env ruby
# coding: utf-8
require 'thor'
require 'json'

class Hash
  def symbolize_keys!
    keys.each do |key|
      self[(key.to_sym rescue key) || key] = delete(key)
    end
    self
  end
end

module Backlog
  module Cli
    class Commands < Thor
      class_option :profile, type: :string, default: 'default', desc: 'profile by .backlogrc'
      map '-v' => :version, '-s' => :find_issue, '-u' => :update_issue, '-n' => :create_issue, '-l' => :list, '-o' => :open

      def initialize(args = [], options = {}, config = {})
        super(args, options, config)
        profile = config[:shell].base.options['profile']
        @core = Backlog::Cli::Core.new(profile)
      end

      desc '-n [project key] -s [issue summary] -d [issue description] --assigner_id [assigner_id]', 'create_issue'
      option :summary, type: :string, aliases: '-s', desc: 'issue summary'
      option :description, type: :string, aliases: '-d', desc: 'issue description'
      option :assignerId, type: :string, desc: 'assigner id, see get_users.'
      def create_issue(project_key)
        puts JSON.pretty_generate(@core.create_issue(project_key.upcase, options))
      end

      desc 'get_comments -k [issue key]', 'get comments'
      option :key, type: :string, aliases: '-k', desc: 'issue key'
      def get_comments
        puts JSON.pretty_generate(@core.get_comments(options))
      end

      desc '-u -k [issue key] -c [issue comment]', 'add comment'
      option :key, type: :string, aliases: '-k', desc: 'issue key'
      option :comment, type: :string, aliases: '-c', desc: 'issue comment'
      def update_issue
        puts JSON.pretty_generate(@core.update_issue(options))
      end

      desc 'get_issue -k [issue key]', 'get issue'
      option :key, type: :string, aliases: '-k', desc: 'issue key'
      def get_issue
        result = @core.get_issue(options)
        puts JSON.pretty_generate(result)
      end

      desc 'open -k [issue key]', 'open issue'
      option :key, type: :string, aliases: '-k', desc: 'issue key'
      def open
        result = @core.get_issue(options)
        `open #{result['url']}`
      end

      desc '-s [project key]', 'find issue'
      option :project_key, type: :string, aliases: '-p', desc: 'project key'
      option :limit, type: :numeric, aliases: '-n', desc: 'limit', default: 10
      option :assignerId, type: :string, desc: 'assigner id, see get_users.'
      option :query, type: :string, aliases: '-q', desc: 'query keyword.'
      option :all, type: :boolean, desc: 'all issue', default: false
      def find_issue(project_key)
        results = @core.find_issue(project_key.upcase, options)
        selected = results.map do |result|
          result.select { |k, v| %w(id url key summary description).include? k }
        end
        puts JSON.pretty_generate(selected.reverse)
      end

      desc '-l [project key] -n [num]', 'list summary'
      option :limit, type: :numeric, aliases: '-n', desc: 'limit', default: 10
      def list(project_key)
        items = @core.get_rss(project_key.upcase).slice(0, options[:limit])
        results = []
        items.each do |item|
          result = {}
          result[:title] = item.title
          result[:content] = item.content
          result[:authors] = item.authors.first
          result[:date_published] = item.date_published
          result[:url] = item.id
          result[:urls] = @core.urls(item.content)
          results << result
        end
        puts JSON.pretty_generate(results.reverse)
      end

      desc 'get_projects', 'get projects'
      def get_projects
        results = @core.get_projects
        puts JSON.pretty_generate(results)
      end

      desc 'get_project_summaries', 'get project summaries'
      def get_project_summaries
        results = @core.get_project_summaries
        puts JSON.pretty_generate(results)
      end

      desc 'get_users [project_key]', 'get users'
      def get_users(project_key)
        results = @core.get_users(project_key.upcase)
        puts JSON.pretty_generate(results)
      end

      desc 'create_issue_by_file ', 'cat issue.txt | backlog-cli create_issue_by_file '
      def create_issue_by_file
        yaml = load_yaml
        project_key = yaml.delete(:project_key)
        @core.create_issue(project_key, yaml)
      end

      desc 'update_issue_by_file [project_key] ', 'cat issue.txt | backlog-cli update_issue_by_file '
      def update_issue_by_file
        @core.update_issue(load_yaml)
      end

      desc '-v', 'show version information'
      def version
        puts Backlog::Cli::VERSION
      end

      private

      def load_yaml
        yaml = YAML.load(STDIN.read)
        yaml.symbolize_keys!
        yaml
      end
    end
  end
end
