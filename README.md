# <a href="http://moroshko.github.io/sliding-puzzle" target="_blank">Sliding Puzzle</a>

## Game Parameters

You can set the following game parameters via the query string:

* `width` - game width (between 3 and 10)
* `height` - game height (between 3 and 10)

## Development

```shell
$ elm package install
$ elm make App.elm --output app.js
$ elm reactor
```

Then, open `http://0.0.0.0:8000/index.html`

## License

[MIT](http://moroshko.mit-license.org)
