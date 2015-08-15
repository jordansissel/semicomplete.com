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

.PHONY: import
import:
	(cd import; find ./ -name '*.txt' -type f | xargs -rt ruby ../import.rb --output ../content/blog)
