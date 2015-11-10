# Sliding Puzzle

### <a href="http://moroshko.github.io/sliding-puzzle?width=4&height=5&start=G,V,I,E,M,O,R,E,T,H,A,N,Y,O,U,,T,A,K,E&goal=G,I,V,E,M,O,R,E,T,H,A,N,Y,O,U,,T,A,K,E&shuffle=0" target="_blank">Play</a>

## Game Parameters

You can set the following game parameters via the query string:

* `width` - game width. Range: [2..10]. Default: 3.
* `height` - game height. Range: [2..10]. Default: 3.
* `start` - start position of the game. For example: `G,V,I,E,M,O,R,E,T,H,A,N,Y,O,U,,T,A,K,E`. When `start` is set, you probably also want to set `shuffle=0`.
* `goal` - end position of the game. For example: `G,I,V,E,M,O,R,E,T,H,A,N,Y,O,U,,T,A,K,E`
* `shuffle` - amount of random moves to play before the game starts. Range: [0..20000]. Default: `(width * height) ^ 2`.
* `size` - tile size in pixels. Range: [5..200]. Default: maximizes the screen space, but doesn't go above 200.

## Development

```shell
$ elm package install
$ ./build.sh
$ elm reactor
```

Then, open `http://0.0.0.0:8000/index.html`

## License

[MIT](http://moroshko.mit-license.org)
