SHELL=/bin/bash

.PHONY: default
default:
	$(MAKE) oldlinks

.PHONY: oldlinks
oldlinks:
	ln -fs blog/projects public/projects
	ln -fs blog/articles public/articles
	set -x; \
	for i in public/blog/{projects,articles}/*/main.html ; do \
		ln -fs main.html $$(dirname $$i)/index.html; \
	done
	@# Put in old 'x.html' shim links to hugo's directory style ones:
	@# foo/bar.html will now symlink to foo/bar/index.html
	@# This is done to keep old hits from google working.
	find public/blog/ -type f -name '*.html' | xargs -tn1 sh -c 'ln -fs  $(basename $(dirname $1))/index.html $(dirname $1).html ' -

.PHONY: import
import:
	(cd import; find ./ -name '*.txt' -type f | xargs -rt ruby ../import.rb --output ../content/blog)
