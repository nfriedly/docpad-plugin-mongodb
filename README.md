# *EXPERIMENTAL* [MongoDB](https://www.mongodb.org/) Importer Plugin for [DocPad](http://docpad.org)

<!-- BADGES/ -->

[![Build Status](http://img.shields.io/travis-ci/nfriedly/docpad-plugin-mongodb.png?branch=master)](http://travis-ci.org/nfriedly/docpad-plugin-mongodb "Check this project's build status on TravisCI")
[![NPM version](http://badge.fury.io/js/docpad-plugin-mongodb.png)](https://npmjs.org/package/docpad-plugin-mongodb "View this project on NPM")
[![Dependency Status](https://david-dm.org/nfriedly/docpad-plugin-mongodb.png?theme=shields.io)](https://david-dm.org/nfriedly/docpad-plugin-mongodb)
[![Development Dependency Status](https://david-dm.org/nfriedly/docpad-plugin-mongodb/dev-status.png?theme=shields.io)](https://david-dm.org/nfriedly/docpad-plugin-mongodb#info=devDependencies)
[![Gittip donate button](http://img.shields.io/gittip/nfriedly.png)](https://www.gittip.com/nfriedly/ "Donate weekly to this project using Gittip")

<!-- /BADGES -->

Import MongoDB collections into DocPad collections.

Inspired by https://github.com/simonh1000/docpad-plugin-mongo and based on https://github.com/docpad/docpad-plugin-tumblr/

## Install

```
docpad install mongodb
```


## Configuration

### Simple example

Add the following to your [docpad configuration file](http://docpad.org/docs/config) via:

``` coffee
plugins:
  mongodb:
    collections: [
      connectionString: "mongodb://localhost/blog" # format is "mongodb://username:password@hostname:port/dbname?options"
      collectionName: "posts"
      relativeDirPath: "blog"
      extension: ".html"
      meta:
        layout: "blogpost"
    ]
```

### Fancy example

``` coffee
plugins:
  mongodb:
    collectionDefaults:
      connectionString: "mongodb://localhost/blog" # format is "mongodb://username:password@hostname:port/dbname?options"

    collections: [
      {
        # connectionString is imported from the defaults
        collectionName: "posts"
        relativeDirPath: "blog"
        extension: '.html.eco'
        injectDocumentHelper: (document) ->
          document.setMeta(
            layout: 'default'
            tags: (document.get('tags') or []).concat(['post'])
            data: """
              <%- @partial('post/'+@document.tumblr.type, @extend({}, @document, @document.tumblr)) %>
              """
          )
      },

      {
        collectionName: "comments"
        extension: '.html.markup'
        meta:
          write: false
      },

      {
        connectionString: "mongodb://localhost/stats"
        collectionName: "stats"
        extension: ".json"
      }
    ]
```

### Config details:

Each configuration object in `collections` inherits defalt values from `collectionDefaults` and then from the built-in defaults:

```coffee
  connectionString: process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || "mongodb://localhost/localdev"
  relativeDirPath: null # defaults to collectionName
  extension: ".json"
  injectDocumentHelper: null
  collectionName: "mongodb"
  meta: {}
```

The default directory for where the imported documents will go inside is the collectionName.
You can override this using the `relativeDirPath` plugin config option.

The default content for the imported documents is JSON data. You can can customise this with the `injectDocumentHelper` plugin configuration option which is a function that takes in a single [Document Model](https://github.com/bevry/docpad/blob/master/src/lib/models/document.coffee).

If you would like to render a template, add a layout, and change the extension, you can this with the [eco](https://github.com/docpad/docpad-plugin-eco) and [partials](https://github.com/docpad/docpad-plugin-partials) plugins and following collection configuration:

``` coffee
extension: '.html.eco'
injectDocumentHelper: (document) ->
  document.setMeta(
    layout: 'default'
    tags: (document.get('tags') or []).concat(['post'])
    data: """
			<%- @partial('post/'+@document.tumblr.type, @extend({}, @document, @document.tumblr)) %>
			"""
  )
```

### Creating a File Listing

As imported documents are just like normal documents, you can also list them just as you would other documents. Here is an example of a `index.html.eco` file that would output the titles and links to all the blog posts from the simple example above:

``` erb
<h2>Blog:</h2>
<ul><% for post in @getCollection('posts').toJSON(): %>
	<li>
		<a href="<%= post.url %>"><%= post.title %></a>
	</li>
<% end %></ul>
```

<!-- HISTORY/ -->

## History
[Discover the change history by heading on over to the `HISTORY.md` file.](https://github.com/docpad/docpad-plugin-tumblr/blob/master/HISTORY.md#files)

<!-- /HISTORY -->


<!-- CONTRIBUTE/ -->

## Contribute

[Discover how you can contribute by heading on over to the `CONTRIBUTING.md` file.](https://github.com/docpad/docpad-plugin-tumblr/blob/master/CONTRIBUTING.md#files)

<!-- /CONTRIBUTE -->

<!-- LICENSE/ -->

## License

Licensed under the incredibly [permissive](http://en.wikipedia.org/wiki/Permissive_free_software_licence) [MIT license](http://creativecommons.org/licenses/MIT/)

Copyright &copy; Bevry Pty Ltd <us@bevry.me> (http://bevry.me)

<!-- /LICENSE -->


