require 'rspec'
require 'yaml'
require 'bosh/template/test'

# The broker's YAML parser silently keeps the last of two identical keys in
# a mapping, so a duplicated key never fails a render; it only drops the
# earlier value. This renders every plan YAML template and fails on any
# mapping that repeats a key, at any depth.
describe 'redis-blacksmith-plans plan templates' do
  let(:root) { File.join(File.dirname(__FILE__), '..') }
  let(:release) { Bosh::Template::Test::ReleaseDir.new(root) }
  let(:job) { release.job('redis-blacksmith-plans') }
  let(:templates_dir) { File.join(root, 'jobs', 'redis-blacksmith-plans', 'templates') }
  let(:props) do
    {
      'environment' => 'lab',
      'bosh_env' => 'lab',
      'service' => { 'type' => 'standalone', 'stemcell' => { 'os' => 'ubuntu-noble', 'version' => 'latest' } },
      'redis' => { 'tls' => { 'enabled' => true, 'dual-mode' => false } }
    }
  end

  def duplicate_keys(node, path = [])
    found = []
    case node
    when Psych::Nodes::Mapping
      seen = Hash.new(0)
      node.children.each_slice(2) do |key, value|
        name = key.respond_to?(:value) ? key.value : key.to_s
        seen[name] += 1
        found.concat(duplicate_keys(value, path + [name]))
      end
      seen.each { |name, count| found << (path + [name]).join('.') if count > 1 }
    when Psych::Nodes::Stream, Psych::Nodes::Document, Psych::Nodes::Sequence
      node.children.each_with_index { |child, i| found.concat(duplicate_keys(child, path + [i])) }
    end
    found
  end

  templates = Dir.glob(File.join(File.dirname(__FILE__), '..', 'jobs', 'redis-blacksmith-plans', 'templates', 'plans', '**', '*.yml'))
  templates = templates.map { |f| f.split('/templates/', 2).last }.sort

  it 'finds the plan templates' do
    expect(templates).not_to be_empty
  end

  templates.each do |tmpl|
    it "has no duplicate keys in #{tmpl}" do
      rendered = job.template(tmpl).render(props)
      expect(duplicate_keys(Psych.parse_stream(rendered))).to eq([])
    end
  end
end
