#!/usr/bin/env ruby
require 'json'
require 'yaml'
require 'net/http'

api_root = 'https://www.dnd5eapi.co'

class Spell

  def initialize uri, id
    @cache_file = ".cache_#{id}"
    if File.exist? @cache_file
      @spell_raw_info = YAML.safe_load(File.read(@cache_file))
    else
      puts "Get #{uri}"
      @spell_raw_info = JSON.parse(Net::HTTP.get uri)
      File.open(@cache_file, 'w+') do |f|
        f.write(YAML.dump @spell_raw_info)
      end
    end
  end

  def get_info
    @spell_raw_info
  end

  def is_for? class_name
    !@spell_raw_info['classes'].collect { |cls| cls['name'] }.select { |cls| cls == class_name }.empty?
  end

  def name
    @spell_raw_info['name']
  end

  def level
    @spell_raw_info['level']
  end

  def ritual?
    @spell_raw_info['ritual']
  end

end

if File::exist?('.cache_spells')
  all_spells = YAML.safe_load(File.read('.cache_spells'))
else
  File.open('.cache_spells', 'w+') { |f|
    all_spells = JSON.parse(Net::HTTP.get(URI("#{api_root}/api/spells")))
    f.write(YAML.dump(all_spells))
  }
end

n_all_spells = all_spells['results'].collect do |raw_desc|
  Spell.new(URI("#{api_root}#{raw_desc['url']}"), raw_desc['index'])
end

druid_spells = n_all_spells.select { |s| s.is_for? 'Druid' and s.ritual? }.collect { |s| s.name }
puts druid_spells