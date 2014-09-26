#!/usr/bin/env ruby
#
# Check All Nodes in Chef Server checked in specific duration
# ===
#
# Copyright 2014 Ryutaro YOSHIBA http://www.ryuzee.com/
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'json'
require 'chef/config'
require 'chef/log'
require 'chef/rest'
require 'chef/node'

class ChefNodeCheck < Sensu::Plugin::Check::CLI
  option :duration,
         description: 'How long ago to checkin',
         short: '-d AGE',
         long: '--duration',
         default: 3600,
         proc: proc { |a| a.to_i }
  option :knife_config,
         description: 'path to knife.rb',
         short: '-k KNIFE_CONFIG',
         long: '--knife_config',
         default: "#{ENV['HOME']}/.chef/knife.rb"

  def run
    Chef::Config.from_file(config[:knife_config])
    message = ''
    result = true
    Chef::Node.list(true).each do |node_array|
      node = node_array[1]
      diff = Time.now.to_i - node[:ohai_time].to_i
      if config[:duration] < diff
        message += "[#{node.name}] #{diff} "
        result = false
      end
    end
    if result
      ok 'All is well'
    else
      critical "Some nodes did not check-in in #{config[:duration]} seconds. #{message}"
    end
  end
end

# ft=ruby encoding=utf-8
