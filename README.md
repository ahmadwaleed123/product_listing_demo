# Product Listing Demo

A small Flutter app built on the public [DummyJSON](https://dummyjson.com) API. You sign in, browse a paginated product list and open a product to see its details.

Test user: `emilys` / `emilyspass`. In debug builds the login form is filled in with this user, so you can sign in with one tap. Release builds start with empty fields.

## Running it

```bash
flutter pub get
flutter run
```

Tests:

```bash
flutter test
```

Built with Flutter 3.41 / Dart 3.11. The iOS minimum is 15.0.

## What it does

* Login with `POST /auth/login`. The access and refresh tokens go into the Keychain on iOS and encrypted storage on Android through `flutter_secure_storage`.
* On launch a splash screen checks for a saved session. If there is one, it loads the profile from `GET /auth/me` and opens the product list; otherwise it opens the login screen. Logging out clears the tokens.
* Product list from `GET /products` with `skip` and `limit` (20 per page). It has a loading state, an error state with retry, an empty state, pull to refresh, and loads the next page as you get near the bottom.
* If a next page fails, the items already loaded stay on screen and a retry button appears at the bottom of the list.
* If a refresh fails while products are showing, the list stays as it is and the error appears in a snackbar.
* Tapping a product opens a detail page with an image gallery, price, discount, rating, stock, description, and shipping, warranty and return info.

## Project structure

```
lib/
  app/                 MaterialApp setup
  core/
    config/            constants, API paths, storage keys
    di/                small service locator
    navigation/        global navigator and snackbar keys
    network/           ApiClient (Dio) and ApiResponse
    routing/           named routes
    storage/           secure storage wrapper
    theme/             colour scheme and component themes
    utils/             debug logging
    widgets/           shared button, text field, state view
  features/
    auth/              api, model, repository, store, view
    splash/            startup screen that loads the profile
    products/          api, model, repository, store, view
test/
  products_store_test.dart
```

Each feature follows the same flow: `view -> store -> repository -> api -> ApiClient`.

## Decisions

State management is Provider with `ChangeNotifier` stores. Each store holds its state behind getters and calls `notifyListeners()` when something changes, and screens rebuild through `Consumer`. There is no code generation, and the product list logic (loading, refreshing, paging and errors) is plain Dart that can be tested without widgets.

`ApiClient` is one Dio instance shared by the whole app. Every call returns a typed `ApiResponse<T>` with the model already parsed, and the API classes turn that into a `(message, data)` record, so the layers above never deal with Dio or raw JSON. Network, timeout and server errors become readable messages in one place.

Token refresh is handled in the client interceptor. On a 401 it calls `POST /auth/refresh` once, even when several requests fail together, then retries the original request. If the server rejects the refresh token, the session is cleared and the app goes back to the login screen. A timeout or lost connection does not log the user out.

Tokens live only in secure storage. They are loaded into memory once at startup so reads stay synchronous, and writes go to the Keychain or Keystore in the background. The user profile stays in memory, and the splash screen fetches it again from `GET /auth/me` after a restart. That call is also what proves the stored token works.

Pagination lives in `ProductsStore`. It tracks `total` from the API to know when to stop, ignores a second `loadMore` while one is in flight, and uses a generation counter so a page that arrives after a refresh can't append to the new list.

The detail page gets the `Product` object from the list. The list response already has every field the page shows, so a second request would only add a loading spinner.

The service locator is a small map of singletons instead of a package. The app only needs a handful of objects, and wiring them in `service_locator.dart` keeps the dependency graph visible in one file. The two app-wide stores (auth and session) are built there and handed to Provider at the top of the app. `ProductsStore` is created by a `ChangeNotifierProvider` on the products route, so its state resets and it is disposed when the screen is left.

The theme is a single seeded `ColorScheme` with a few overrides, and widgets read colours from the theme instead of hard coding them.

Tests cover the store: first load, paging to the end, first page error, next page error, empty result and refresh. They run against a fake repository, so no network is needed.

With more time I would add search and category filters (DummyJSON supports both), widget tests for the list states, and a flavour setup for separate environments.

## How I work

I keep a set of reusable services I've refined across projects: the Dio client with token refresh, secure storage, error handling and the base state classes. I reuse and adapt them for each new app, so setup is fast and consistent. I also use Claude Code to speed up boilerplate and repetitive parts, but I review and understand every line that goes in. This test task uses the same structure.
