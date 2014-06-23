#!/usr/bin/env ruby
# coding: utf-8

require 'xmlrpc/client'
require 'yaml'
require 'feed-normalizer'

module Backlog
  module Cli
    class Core
      DOMAIN = 'backlog.jp'
      def initialize(profile)
        info = YAML.load_file("#{ENV['HOME']}/.backlogrc")[profile]
        @user = info['user']
        @space = info['space']
        @password = info['password']
        @assigner_id = info['assigner_id']
        api_url = "https://#{@user}:#{@password}@#{@space}.#{DOMAIN}/XML-RPC"
        @server = XMLRPC::Client.new2(api_url)
      end

      def create_issue(project_key, options)
        args = options.dup
        args[:projectId] = get_project(project_key)['id']
        args[:assignerId] = options[:assigner_id].nil? ? @assigner_id : options[:assigner_id]
        @server.call('backlog.createIssue', args)
      end

      def add_comment(options)
        args = { key: options[:key], content: options[:content] }
        @server.call('backlog.addComment', args)
      end

      def get_comments(options)
        issue_id = get_issue(options)['id']
        @server.call('backlog.getComments', issue_id)
      end

      def update_issue(options)
        args = { key: options[:key], comment: options[:comment] }
        @server.call('backlog.updateIssue', args)
      end

      def get_issue(options)
        @server.call('backlog.getIssue', options[:key])
      end

      def find_issue(project_key, options)
        args = options.dup
        args[:projectId] = get_project(project_key)['id']
        args[:statusId] = [1, 2, 3]
        args[:sort] = 'UPDATED'
        if options[:all]
          args.delete(:assignerId)
        else
          args[:assignerId] = @assigner_id
        end
        @server.call('backlog.findIssue', args)
      end

      def get_projects
        @server.call('backlog.getProjects')
      end

      def get_project_summaries
        @server.call('backlog.getProjectSummaries')
      end

      def get_users(project_key)
        @server.call('backlog.getUsers', get_project(project_key)['id'])
      end

      def get_rss(project_key)
        feed = FeedNormalizer::FeedNormalizer.parse open(
          "https://#{@space}.#{DOMAIN}/rss/#{project_key}", http_basic_authentication: [@user, @password]
        )
        feed.items
      end

      def urls(body)
        regex = /https?\:\/\/[-_.!~*'()a-zA-Z0-9;\/?:@&=+$,%#]+/
        body.scan(regex).uniq.sort.reverse
      end

      private

      def get_project(project_key)
        @server.call('backlog.getProject', project_key)
      end
    end
  end
end
