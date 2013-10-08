# Request

A simple http/net wrapper to make http request easy.

Inspired by request.js

## Installation

Add this line to your application's Gemfile:

    gem 'request'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install request

## Usage

> How to fork it?

```ruby
Request["https://api.github.com/repo/v2e4lisp/request/forks"].auth("user", "pass").post
```

> Send data(get).

```ruby
Request[url].send(a: 1, b: 2).get
```

> Post json

```ruby
Request[url].send(a: 1, b: 2).send(c: 3).type(:json).post
```

> Post form

```ruby
Request[url].send(field1: "username").send(field2: "password").type(:form).post
```

> Post form with file(multipart form)

```ruby
Request[url].send(field1: "username").send("file", csv_file, "optional-filename").post
```

> With a block

```ruby
Request.new(url) do |req|
  req.send(x: 1, y: 2)
  req.post
end
```

> some other simple API

* write(string): write to body
* header(hash) : write to header
* reset        : reset body and header
* get(n)       : get with redirection limit default is 4
* url=         : reset url
* use_ssl(bool): turn on/off ssl. It will be auto turned on when scheme is "https"
* mulit(bool)  : multipart form header. Auto turned on when files detected
* type()       : specify content-type (:text,:json,:html,:xml,:form)



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
