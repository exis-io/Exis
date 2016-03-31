<div align="center">
    <h1>Join the Chat!
    <br>
    <a href="http://slack.exis.io"><img src="http://slack.exis.io/badge.svg"></a>
    </h3>
</div>

# ngRiffle

ngRiffle is an AngularJS wrapper for [jsRiffle](https://github.com/exis-io/jsRiffle) 




## Installing ngRiffle

#### With Bower
You can install ngRiffle via [Bower](http://bower.io/#install-bower):

```bash
$ bower install ngRiffle --save
```

To use ngRiffle in your project, you need to include the following files in your HTML:

```html
<!-- AngularJS -->
<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.2.26/angular.min.js"></script>

<!-- jsRiffle -->
<script src="bower_components/jsRiffle/release/jsRiffle.min.js"></script>

<!-- ngRiffle -->
<script src="bower_components/ngRiffle/release/ngRiffle.min.js"></script>
```

#### With NPM

```bash
$ npm install ngriffle
```
```html
<!-- AngularJS -->
<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.2.26/angular.min.js"></script>

<!-- jsRiffle -->
<script src="node_modules/jsRiffle/release/jsRiffle.min.js"></script>

<!-- ngRiffle -->
<script src="node_modules/ngRiffle/release/ngRiffle.min.js"></script>
```

```js

// module definition
export default angular.module('app.starter', [ngRiffle])
    .config(function($riffleProvider) {
        $riffleProvider.setDomain("YOUR.APP.DOMAIN.HERE");
    })
    .run(function($riffle){
        $riffle.setToken("APP_TOKEN");
        $riffle.join();
    });

angular.bootstrap(document, ['app.starter']);

```
Check out our [Documentation](https://exis.io/docs/API-Reference/ngRiffle)

