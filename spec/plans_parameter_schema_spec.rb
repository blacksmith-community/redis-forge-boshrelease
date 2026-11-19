require 'rspec'
require 'json'
require 'bosh/template/test'

# The broker refuses a parameter the plan's schema doesn't declare, so
# the schema has to name every meta.params key the plan manifests read.
describe 'redis-blacksmith-plans parameter schema' do
  let(:root) { File.join(File.dirname(__FILE__), '..') }
  let(:job_dir) { File.join(root, 'jobs', 'redis-blacksmith-plans') }
  let(:schema) { JSON.parse(File.read(File.join(job_dir, 'templates', 'plans', 'schema.json'))) }
  let(:read_keys) do
    Dir.glob(File.join(job_dir, 'templates', 'plans', '*', 'manifest.yml'))
       .flat_map { |file| File.read(file).scan(/meta\.params\.([A-Za-z0-9_-]+)/).flatten }
       .uniq.sort
  end

  it 'names draft-04 and declares every meta.params key the manifests read' do
    expect(schema['$schema']).to eq('http://json-schema.org/draft-04/schema#')
    expect(read_keys).not_to be_empty
    expect(schema['properties'].keys.sort).to eq(read_keys)
  end

  it 'does not open the schema to undeclared keys' do
    expect(schema).not_to have_key('additionalProperties')
  end

  it 'ships schema.json with the job and copies it into each plan' do
    spec = File.read(File.join(job_dir, 'spec'))
    expect(spec).to include('plans/schema.json')

    script = Bosh::Template::Test::ReleaseDir.new(root).job('redis-blacksmith-plans')
      .template('bin/configure-blacksmith')
      .render({ 'environment' => 'lab', 'plans' => { 'one' => { 'type' => 'standalone' }, 'two' => { 'type' => 'cluster', 'masters' => 3 } } })
    expect(script.scan('schema.json').length).to be >= 2
  end
end
