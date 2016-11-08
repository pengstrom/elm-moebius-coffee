// pull in desired CSS/SASS files
require( './styles/style.scss' );

// inject bundled Elm app into div#main
var Elm = require( './Main' );
// Elm.Main.embed( document.getElementById( 'main' ) );
Elm.Main.fullscreen();
