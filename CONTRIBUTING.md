# Contributing

Thanks for taking the time to submit a pull request!  These are the few
guidelines to keep things coherent.

[Fork the project](http://github.com/arnau/ISO8601/fork) and clone.

Create your _feature_ branch:

```sh
git checkout -b features/xyz
```

Set up your machine.  I recommend using [Docker](https://docker.com):

```sh
make install
```

But of course you can go raw style

```sh
bundle install
```

Add your code and tests and check it passes:

```sh
make test  # mri, rbx, jruby
# or
make mri-test
make rbx-test
make jruby-test
```

Or raw style

```sh
bundle exec rspec
```

Although not required, try to adhere to Rubocop's checks:

```sh
make check
```

Or raw style

```sh
bundle exec rubocop
```

Push your branch and submit a [Pull Request](https://github.com/arnau/iso8601/compare/).

Add a description of your proposed changes and why they are needed.

I'll review it as soon as I can.
