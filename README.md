# <a href="http://moroshko.github.io/sliding-puzzle" target="_blank">Sliding Puzzle</a>

## Game Parameters

You can set the following game parameters via the query string:

* `width` - game width. Range: [3..10]. Defaults to 3.
* `height` - game height. Range: [3..10]. Defaults to 3.
* `tileSize` - tile size in pixels. Range: [5..200]. Defaults to maximaze the screen space, but doesn't go above 200.

## Development

```shell
$ elm package install
$ elm make App.elm --output app.js
$ elm reactor
```

Then, open `http://0.0.0.0:8000/index.html`

## License

[MIT](http://moroshko.mit-license.org)
