Gem::Specification.new do |s|
  s.name = 'heroku_whiz'
  s.version = '0.2.0'
  s.summary = 'Handy (experimental) Heroku gem for noobs to create a simple Heroku app in a whiz!'
  s.authors = ['James Robertson']
  s.files = Dir['lib/heroku_whiz.rb']
  s.add_runtime_dependency('clipboard', '~> 1.3', '>=1.3.6')
  s.add_runtime_dependency('launchy', '~> 2.5', '>=2.5.0')
  s.signing_key = '../privatekeys/heroku_whiz.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'digital.robertson@gmail.com'
  s.homepage = 'https://github.com/jrobertson/heroku_whiz'
end
