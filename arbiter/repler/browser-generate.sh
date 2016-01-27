#!/bin/bash

# Create a temp html file
cat >browser.html <<EOF
<html>
<body>
    <div id="results"></div>
    <script>

EOF

# Drop in the jsriffle lib to make it easy
cat ./jsRiffle.js >> browser.html

# End the jsriffle lib...
cat >>browser.html <<EOF

</script>

EOF

# Drop in our testing code and end the html!
cat >>browser.html <<EOF
<script>
    // Overwrite console.log b/c its easier to do selenium testing by looking for element id's then log statements
    console.log = function(s) {
        document.getElementById("results").innerHTML = s;
    };
    var riffle = jsRiffle;
    riffle.SetFabric("$WS_URL");

    var app = riffle.Domain("$DOMAIN");
    var backend = app.Subdomain("example");
    var client = app.Subdomain("example");

    backend.onJoin = function() {
        $EXIS_REPL_CODE
    };

    backend.Join()
</script>
</body>
</html>
EOF
