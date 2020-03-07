## [0.5.2] - March 7, 2020

* Add serializer support for Firebase
* Reformat Specification Architecture
* Remove Algo. User `fcode_common` for Algo.

## [0.5.1]

* Provide a interface for DBModel so that it can be used with built_value package

## [0.5.0]

* Added Documentation
* Moved some functionality from Repository to RepositoryAddon
* DBModel is now immutable
* Minor bug fixes and performance improvements

## [0.4.8]

* Added Transformers
* Library updates
* Minor bug fixes

## [0.4.7] - Update dependencies  to the latest version

## [0.4.6]

* Minor bug fixes

## [0.4.5]

* Update dependencies
* Minor bug fixes and document updates

## [0.4.4] 

* ByReference and ByReferences specifications were removed
* Remove all listeners
* Remove collection reference handler

If you want to listen to something, use provided stream. Old listeners
are not available now.

## [0.4.3] - Query for single values with Futures

## [0.4.2] - Transactions and Batch Writes

## [0.4.1] - Repository update function changes

Now you can update arrays or update only few fields in a documents

## [0.4.0] - Remove all dependencies from flutter_bloc and bloc by @felangel

As all the previously mission features are already there in 
flutter_bloc, this package removes all the dependencies from it.
For BLoC, use that package.

## [0.3.8] - Remove close() from DB and UI Models

`close()` is there to dispose any db connections or streams when the
model is not using. But models should not depend on anything in the code.
So this was removed.


## [0.3.7] - Update dependencies to the newest version

## [0.3.6] - Update dependencies to the newest version

## [0.3.5] - Implement remove function in Repository

## [0.3.3]
 
* Add assertions
* Add Streams to Handlers
* Add CollectionReference to Handler

## [0.3.2] - Remove Firebase Auth

## [0.3.1] - Put class to sep files

* Put classes in BLoC into separate files
* Make UIModel immutable

## [0.3.0] - Use flutter_bloc and bloc by @felangel

## [0.2.10] - Modify Docs

## [0.2.8] 

* Modify Docs
* Firebase Cloud Functions support added
* Added Listeners to reference/s handlers
* Model List Builder added

## [0.2.7] 

* Bug Fixes
* New way of handling listeners in BLoC
* Model Builder works with listeners
* Model Stream Builder added
* Multi Model Builder added
* Make Model Builder Stateful

## [0.2.6] 

* Bug fixes
* DB model can have custom IDs
* Move everything to src
* Action Listener is called before it's added to the hook
* Update dependencies
* Global BLoC collector

## [0.2.5] 

* Bloc Listener has a new way of communicating with listeners
* Bloc has raise errors
* Bloc can manually call a state change
* Performance improvements in BLoC

## [0.2.4] - Text start with Specification added

## [0.2.3] 

* By ID Specification added
* Reference/References handler added

## [0.2.2] 

* By Reference Specification added
* Remove transformer

## [0.2.1] - Replace hook with rx

## [0.2.0] - Change package name
