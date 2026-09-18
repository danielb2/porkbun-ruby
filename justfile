_default:
    @just -l

test:
    mise exec -- env BUNDLE_PATH=.bundle bundle exec rake

publish: test
    mise exec -- env BUNDLE_PATH=.bundle bundle exec rake release
