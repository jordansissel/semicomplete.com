+++
# Imported from original pyblosxom .txt format at 2015-08-14
date = "2010-11-27T01:14:37-08:00"
title = "Puppet \"pure fact-driven\" nodeless configuration\n"
type = "old"
categories = [ "old" ]
tags = ["puppet", "nodeless", "nodes", "classifier", "truth"]
+++

Truth should guide your configuration management tools.

Truth in this case is: what machines you have, properties of those machines,
roles for those machines, etc. For example "foo-1.a.example.com is a webserver"
is a piece of truth. Where and how you store truth is up to you and out of
scope for this post.

My goal is to have truth steer everything about my infrastructure. Roles, jobs,
and even long-term one-offs get put into the truth source (like a machine role,
etc). That way, if the machine with a one-off dies, I can just add that
machine role to another system and puppet will configure it - no pain and no
fire to fight.

A simple example of truth in puppet is puppet's "node" type. A simple example:

```
node "foo-1.a.example.com" {
  include apache
}
```

Specifying each node in puppet doesn't scale very well for many people.
Further, you may already have your node information in another tool (ldap,
mysql, etc).  To allow this, puppet lets you feed 'node' information from an
external tool (called an [external node classifier](http://docs.puppetlabs.com/guides/external_nodes.html)). However, I found that using an external node classifier also
has its drawbacks (also out of scope for this post).

To avoid complex logic in a node classifier, I've got with a pure fact-based
puppet configuration which I call "nodeless."

My puppet site.pp looks basically like this:

```
node default {
  include truth::enforcer
}
```

That's it. No extra nodes, no 'include' or conditionals randomly sprayed around.

From there, I have the truth::enforcer class include other classes, do sanity
checking, etc, all based on facts (and properties if you use external node
classifier)

Fully standalone example with code can be found in [jordansissel/puppet-examples](https://github.com/jordansissel/puppet-examples/tree/master/nodeless-puppet/).