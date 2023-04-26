workspace {
    model {
        publicUser = person "Public" "Public User"
        authorizedUser = person "Authorized" "Authorized User"
        bookStoreSystem = softwareSystem "Books Store System" "Allows users to interact with book records." "Books Store System" {
            searchWebApi = container "Search Web API" "Allows only authorized users searching books records via HTTPs handlers" "Go and ElasticSearch"
            adminWebApi = container "Admin Web API" "Allows only authorized users administering books details via HTTP handlers" "Go and PostgreSQL" {
                bookService = component "Book Service" "Allow administering books details"
                authorizationService = component "Authorization Service" "Authorizes books detail"
                eventsPublisherSerivce = component "Events Publisher Service" "Publishes books-related events"
            }
            publicWebApi = container "Public Web API" "Reads data from Read/Write Relational Database"
            elasticSearch = container "ElasticSearch Events Consumer" "Listening to Kafka domain events and write publisher to Search Database for updating" "Go"
            searchDb = container "Search Database" "Stores searchable books details" "ElasticSearch"
            database = container "Database" "Stores books details" "PostgreSQL" "Database"
            readerCache = container "Reader Cache" "Caches books details" "Memcached"
            publisherRecurrentUpdater = container "Publisher Recurrent Updater" "It uses the Admin Web API for updating that data" "Kafka"
            #External
            bookKafkaSystem = container "Book Kafka System" "Handles book-related domain events" "Apache Kafka 3.0"
        }
        publiserSystem = softwareSystem "Publisher System" "Provides information about books published by different publishers." "External System"

        #External System
        authorizationSystem = softwareSystem "Authorization System" "Provides authentication and authorization services." "External System"
        
        #Relationship System context
        publicUser -> bookStoreSystem "View detailed information about published books"
        authorizedUser -> bookStoreSystem "View administering books"
        bookStoreSystem -> authorizationSystem "Authorization purposes using"
        bookStoreSystem -> publiserSystem "Get details about books published using"

        # Relationship between Containers
        authorizationSystem -> searchWebApi "Allow authorized users to" "HTTPs"
        searchWebApi -> searchDb "Uses"
        authorizationSystem -> adminWebApi "Allow authorized users to" "HTTPs"
        adminWebApi -> database "Read/Write relational database"
        adminWebApi -> bookKafkaSystem "Publishes events to"
        publicUser -> publicWebApi "Getting books details"
        publicWebApi -> database "Read data from"
        publicWebApi -> readerCache "Reads/write data to"
        elasticSearch -> bookKafkaSystem "Listening to"
        elasticSearch -> searchDb "Write publisher to"
        publisherRecurrentUpdater -> publiserSystem "Listening to external events coming and updates DB with detail from"
        publisherRecurrentUpdater -> adminWebApi "Uses for updating data"

        # Relationship between Components
        authorizationSystem -> authorizationService "Allows authorizing users to"
        eventsPublisherSerivce -> bookKafkaSystem "Publishes books-related domain events to"
        bookService -> database "Read form and write data to"
        authorizationService -> bookService "Authorizes books to"
        bookService -> eventsPublisherSerivce "Uses"
    }

    // Define the views
    views {
        systemContext bookStoreSystem "SystemContext" {
            include *
            autoLayout
        }

        container bookStoreSystem "Containers" {
            include *
            autoLayout
        }

        component adminWebApi "Components" {
            include *
            autoLayout
        }

        styles {
            element "External System" {
                background #999999
                color #ffffff
            }

            relationship "Relationship" {
                dashed false
            }

            relationship "Async Request" {
                dashed true
            }

            element "Database" {
                shape Cylinder
            }
        }

        theme default
    }
}
