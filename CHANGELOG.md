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
