Spotify iOS SDK Beta 4
======================

**What's New**

* Added support for the "Implicit Grant" authentication flow. This flow doesn't
  require a Token Swap Service, but sessions only last an hour and you'll have
  to re-authenticate the user via Safari.

* Audio is now cached to storage during playback, improving the playback
  experience significantly. See the new `SPTAudioStreamingController` APIs
  for controlling the cache
  ([Issue #68](https://github.com/spotify/ios-sdk/issues/68)).

* Added support for the "Your Music" feature with the following APIs on
  `SPTRequest`:
  * `+savedTracksForUserInSession:callback:` to get a user's saved tracks.
  * `+saveTracks:forUserInSession:callback:` to save new tracks.
  * `+removeTracksFromSaved:forUserInSession:callback` to un-save tracks.
  * `+savedTracksContains:forUserInSession:callback` to check if track(s) are
    saved without downloading the whole list.

  ([Issue #5](https://github.com/spotify/ios-sdk/issues/5)).

* Added `[SPTArtist -requestRelatedArtists:callback:]` to request an artist's
  related artists.

* Added `[SPTPlaylistSnapshot -setTracksInPlaylist:withSession:callback:]`

* Added `[SPTPlaylistSnapshot -changePlaylistDetails:withSession:callback:]`
  ([Issue #67](https://github.com/spotify/ios-sdk/issues/67)).


**Bugs Fixed**

* Bitrate constants are documented correctly
  ([Issue #86](https://github.com/spotify/ios-sdk/issues/86)).

* Playback error codes are documented correctly
  ([Issue #91](https://github.com/spotify/ios-sdk/issues/91)).

* Creating playlists now works correctly
  ([Issue #90](https://github.com/spotify/ios-sdk/issues/90)).

* `SPTListPage` objects returned from search requests now return correct results
  when calling `-requestNextPageWithSession:callback:`
  ([Issue #87](https://github.com/spotify/ios-sdk/issues/87)).

* `[SPTAudioStreamingController -seekToOffset:callback:]` now works correctly when
  called within the `-playURI:` callback block
  ([Issue #70](https://github.com/spotify/ios-sdk/issues/70)).

* The library now works in the 64-bit iOS Simulator
  ([Issue #11](https://github.com/spotify/ios-sdk/issues/11)).

* The `[SPTAudioStreamingController -currentTrackMetadata]` property now
  correctly returns metadata
  ([Issue #101](https://github.com/spotify/ios-sdk/issues/101)).

* Scopes are now working properly
  ([Issue #99](https://github.com/spotify/ios-sdk/issues/99)).

Spotify iOS SDK Beta 3
======================

**What's New**

* `SPTAuth` and `SPTSession` has been completely rewritten to use the new Spotify
  authentication stack. This means that you need to re-do your auth code.
  Additionally, the Client ID and Client Secret provided with earlier betas will
  no longer work. See the main readme for more information
  ([Issue #3](https://github.com/spotify/ios-sdk/issues/3)).

  * The Basic Auth demo project has been rewritten to be much more friendly for
  new users to understand what's going on.

  * You'll need to update your Token Swap Service for the new auth flow. A new
  example is provided with the SDK.

* Added `SPTArtist` convenience getters for albums and top lists:
  `-requestAlbumsOfType:withSession:availableInTerritory:callback:` and
  `-requestTopTracksForTerritory:withSession:callback:`
  ([Issue #44](https://github.com/spotify/ios-sdk/issues/44),
  [Issue #34](https://github.com/spotify/ios-sdk/issues/34)).

* Added ability to get the user's "Starred" playlist using `SPTRequest`'s
  `+starredListForUserInSession:callback:` method
  ([Issue #15](https://github.com/spotify/ios-sdk/issues/15)).

* Various API changes and additions to metadata objects. In particular, users may
  be interested in the availability of album art on `SPTPartialAlbum` and track
  count and owner properties on `SPTPartialPlaylist`
  ([Issue #23](https://github.com/spotify/ios-sdk/issues/23)).

* `SPTAudioStreamingController` now has a customisable streaming bitrate.

* Added ability to get detailed information about the logged-in user using
  `SPTRequest`'s `+userInformationForUserInSession:callback:` method
  ([Issue #40](https://github.com/spotify/ios-sdk/issues/40)).

* Added `SPTListPage` class to deal with potentially large lists in a sensible
  manner. Objects with potentially long lists (playlist and album tracks lists,
  search results, etc) now return an `SPTListPage` to allow you to paginate
  through the list.


**Bugs Fixed**

* Core metadata classes now work properly
  ([Issue #52](https://github.com/spotify/ios-sdk/issues/52) and a bunch of others).

* Delegate methods are now marked `@optional`
  ([Issue #41](https://github.com/spotify/ios-sdk/issues/41)).

* Playlists not owned by the current user can be requested as long as your
  application has permission to do so
  ([Issue #10](https://github.com/spotify/ios-sdk/issues/10)).

* `SPTAudioStreamingController` now calls the `audioStreaming:didChangeToTrack:`
  delegate method with a `nil` track when track playback ends
  ([Issue #21](https://github.com/spotify/ios-sdk/issues/21)).

* `SPTAudioStreamingController` is more aggressive at clearing internal audio
  buffers ([Issue #46](https://github.com/spotify/ios-sdk/issues/46)).

* `SPTAudioStreamingController` no longer crashes on 64-bit devices when calling
  certain delegate methods ([Issue #45](https://github.com/spotify/ios-sdk/issues/45)).

* `SPTAuth` no longer crashes when handling an auth callback URL triggered by the
  user pushing "Cancel" when being asked to log in
  ([Issue #38](https://github.com/spotify/ios-sdk/issues/38)).

* Included .docset now correctly works with Xcode and Dash
  ([Issue #12](https://github.com/spotify/ios-sdk/issues/12)).


Spotify iOS SDK Beta 2
======================

**What's New**

* Special release for Music Hackday Paris. Hi, hackers!

* `SPTAudioStreamingController` now allows initialization with a custom audio output controller ([Issue #19](https://github.com/spotify/ios-sdk/issues/19)).

* `SPTTrackPlayer` now has an observable `currentPlaybackPosition` property ([Issue #28](https://github.com/spotify/ios-sdk/issues/28)).

* Various API changes and additions to metadata objects. In particular, users may be interested in the availability of album art on `SPTAlbum`, artist images on `SPTArtist` and 30 second audio previews on `SPTTrack` ([Issue #1](https://github.com/spotify/ios-sdk/issues/1)).

* The Simple Track Player example project now shows cover art in accordance with the above.


**Bugs Fixed**

* `SPTAudioStreamingController` now more reliably updates its playback position when seeking ([Issue #33](https://github.com/spotify/ios-sdk/issues/33)).

* `SPTTrackPlayer` now respects the index passed into `-playTrackProvider:fromIndex:` ([Issue #14](https://github.com/spotify/ios-sdk/issues/14)).

* `NSError` objects caused by audio playback errors are now more descriptive ([Issue #8](https://github.com/spotify/ios-sdk/issues/8)).


**Known Issues**

* Building for the 64-bit iOS Simulator doesn't work.

* For other open issues, see the project's [Issue Tracker](https://github.com/spotify/ios-sdk/issues).


Spotify iOS SDK Beta 1
=============

**What's New**

* Initial release.

**Known Issues**

* No cover art APIs. ([#1](https://github.com/spotify/ios-sdk/issues/1))

* Cannot remove items from playlists. ([#2](https://github.com/spotify/ios-sdk/issues/2))

* Sessions will expire after one day, even if persisted to disk. At this point,
you'll need to re-authenticate the user using `SPAuth`. ([#3](https://github.com/spotify/ios-sdk/issues/3))
