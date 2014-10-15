# *EXPERIMENTAL* [MongoDB](https://www.mongodb.org/) Importer Plugin for [DocPad](http://docpad.org)

Import MongoDB collections into DocPad collections. Doesn't actually work yet.


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
    connectionString: "mongodb://localhost/blog" # format is "mongodb://username:password@hostname:port/dbname?options"
    collections: [
      collectionName: "posts"
      relativeDirPath: "blog"
      extension: ".md.html"
        meta:
          layout: "blogpost"
    ]
```

### Customising the Output

The default directory for where the imported documents will go inside is the collectionName.
You can customise this using the `relativeDirPath` plugin configuration option, the above example shows the `posts` collection going into the .

The default extension for imported documents is `.json`. You can customise this with the `extension` plugin configuration option.

The default content for the imported documents is the serialised tumblr data as JSON data. You can can customise this with the `injectDocumentHelper` plugin configuration option which is a function that takes in a single [Document Model](https://github.com/bevry/docpad/blob/master/src/lib/models/document.coffee).

If you would like to render a partial for the tumblr data type, add a layout, and change the extension, you can this with the following plugin configuration:

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

As imported documents are just like normal documents, you can also list them just as you would other documents. Here is an example of a `index.html.eco` file that would output the titles and links to all the imported tumblr documents:

``` erb
<h2>Blog:</h2>
<ul><% for file in @getFilesAtPath('blog/').toJSON(): %>
	<li>
		<a href="<%= file.url %>"><%= file.title %></a>
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


