# Prepare
{MongoClient} = require("mongodb")
{TaskGroup} = require('taskgroup')
_ = require('lodash')

# Export
module.exports = (BasePlugin) ->
  # Define
  class MongodbPlugin extends BasePlugin
    # Name
    name: 'mongodb'

    # Config
    config:
      collectionDefaults:
        connectionString: process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || "mongodb://localhost/localdev"
        relativeDirPath: null # defaults to collectionName
        extension: ".json"
        injectDocumentHelper: null
        collectionName: "mongodb"
        meta: {}
      collections: []

    # =============================
    # Events

    # DocPad v6.24.0+ Compatible
    # Configuration
    setConfig: ->
      # Prepare
      super
      config = @getConfig()
      # Adjust
      config.collections = config.collections.map (collection) ->
        return _.defaults(collection, config.collectionDefaults)
      # Chain
      @

    # Fetch our documents from mongodb
    # next(err, mongoDocs)
    fetchMongodbCollection: (collectionConfig, next) ->

      MongoClient.connect collectionConfig.connectionString, (err, db) ->
        return next err if err
        db.collection(collectionConfig.collectionName).find().toArray (err, mongoDocs) ->
          db.close()
          next err, mongoDocs
      # Chain
      @

    # convert JSON doc from mongodb to DocPad-style document/file model
    # "body" of docpad doc is a JSON string of the mongo doc, meta includes all data in mongo doc
    mongoDocToDocpadDoc: (collectionConfig, mongoDoc) ->
      # Prepare
      docpad = @docpad

      documentAttributes =
        data: JSON.stringify(mongoDoc, null, '\t')
        meta: _.defaults(
          collectionConfig.meta,

          mongoId: mongoDoc._id
          mongodbCollection: mongoDoc.collectionName
          # todo check for ctime/mtime/date/etc. fields and upgrade them to Date objects (?)
          relativePath: "#{collectionConfig.relativeDirPath or collectionConfig.collectionName}/#{mongoDoc._id}#{collectionConfig.extension}",

          mongoDoc
        )

      # Fetch docpad doc (if it already exists in docpad db, otherwise null)
      document = docpad.getFile({mongoId:mongoDoc._id})


      # Existing document
      if document?
        # todo: check mtime (if avaliable) and return now docs that haven't changed
        document.set(documentAttributes)

        # New Document
      else
        # Create document from opts
        document = docpad.createDocument(documentAttributes)

      # Inject document helper
      collectionConfig.injectDocumentHelper?.call(@, document)

      # Return the document
      return document

    insertDocpadDoc: (document, next) ->
      # Load the document
      document.action 'load', (err) ->
        # Check
        return next(err, document)  if err

        # Add it to the database (with b/c compat)
        docpad.addModel?(document) or docpad.getDatabase().add(document)

        # Complete
        next(null, document)

    # =============================
    # Events

    # Populate Collections
    # Import MongoDB Data into the Database
    populateCollections: (opts, next) ->
      # Prepare
      plugin = @
      docpad = @docpad
      config = @getConfig()

      # Imported
      imported = 0

      # Log
      docpad.log('info', "Importing MongoDB collection(s)...")

      # concurrency:0 means run all tasks simultaneously
      collectionTasks = new TaskGroup({concurrency:0}).once 'complete', (err) ->
        return next(err) if err

        # Log
        docpad.log('info', "Imported all mongodb docs...")

        # Complete
        return next()

      config.collections.forEach (collectionConfig) ->
        collectionTasks.addTask (next) ->
          plugin.fetchMongodbCollection collectionConfig, (err, mongoDocs) ->
            return next(err) if err

            docTasks  = new TaskGroup({concurrency:0}).once 'complete', (err) ->
              return next(err) if err
              docpad.log('debug', "Retrieved #{mongoDocs.length} mongo in collection #{collectionConfig.collectionName}, converting to DocPad docs...")

            mongoDocs.forEach (mongoDoc) ->
              docTasks.addTask (next) ->
                docpadDoc = plugin.mongoDocToDocpadDoc(collectionConfig, mongoDoc)
                docpad.log('debug', "Inserting #{docpadDoc.get('relativePath')} into DocPad database...")
                plugin.insertDocpadDoc docpadDoc, next

            docTasks.run()

      collectionTasks.run()

      # Chain
      @

      # Extend Collections
      # Create our live collection(s) from the docs we inserted into the db
      extendCollections: ->
        # Prepare
        config = @getConfig()
        docpad = @docpad

        config.collections.forEach (collectionConfig) ->
          # Create the collection
          mongoCollection = docpad.getFiles({mongodbCollection: collectionConfig.collectionName}, collectionConfig.sortBy)

          # Set the collection
          docpad.setCollection(collectionConfig.collectionName, mongoCollection)

          docpad.log('debug', "Created DocPad collection #{collectionConfig.collectionName}")

        # Chain
        @
