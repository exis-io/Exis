module.exports = {};
var exp = module.exports;
var request = require('request');
var Q = require('q');
var fs = require('fs');
var mimetype = require('mimetype');

var registrar = 'https://node.exis.io:8880';
exp.setRegistrar = function(url){
  registrar = url;
}

if(process.env.WS_URL){
  var url = process.env.WS_URL.trim().replace(/^wss/g, 'https').replace(/^ws/g, 'http').replace(/:8000(\/wss?)?/g, ':8880');
  exp.setRegistrar(url);
}

exp.loginAnonymous = function(){
  var p = Q.defer();
  getToken({domain: "", password: "", requestingdomain: this.getName()}, p, this);
  return p.promise;
};

exp.loginUsernameOnly = function(user){
  var p = Q.defer();
  getToken({domain: user.username, password: "", requestingdomain: this.getName()}, p, this);
  return p.promise;
};

exp.login = function(user){
  var p = Q.defer();
  getToken({domain: user.username || '', password: user.password || '', requestingdomain: this.getName()}, p, this);
  return p.promise;
};

exp.registerAccount = function(user){
  var p = Q.defer();
  register({"domain": user.username, "domain-password": user.password, "domain-email": user.email, "Name": user.name, "requestingdomain": this.getName()}, p, this);
  return p.promise;
};

exp.uploadUserFile = function(path, name, collection, conn){
  var p = Q.defer();
  putUserObject(path, name, collection, conn, p);
  return p.promise;
};

exp.uploadFile = function(path, name, conn){
  var p = Q.defer();
  putObject(path, name, conn, p);
  return p.promise;
};

function getToken(body, promise, conn){

  request.post({
    url: registrar + '/login',
    form: JSON.stringify(body)
  },
  function(err, resp, body){
    if(err){
      promise.reject(err);
    }else if(resp.statusCode !== 200){
      promise.reject(body);
    }else{
      body = JSON.parse(body);
      var d = conn.linkDomain(body.domain);
      d.setToken(body.login_token);
      promise.resolve(d);
    }
  });
}

function register(body, promise, conn){

  request.post({
    url: registrar + '/register',
    form: JSON.stringify(body)
  },
  function(err, resp, body){
    if(err){
      promise.reject(err);
    }else if(resp.statusCode !== 200){
      promise.reject(body);
    }else{
      promise.resolve("Successful Registration.");
    }
  });
}

function putUserObject(path, name, collection, conn, promise){
    conn.call('uploadUserFile', name, mimetype.lookup(path), collection).then(function(url){
      try{
        var body = fs.readFileSync(path);
      }catch (e){
        promise.reject("Couldn't read file at specified path");
        return;
      }
      request.put({
        url: url,
        body: body,
        headers: {
          'x-amz-acl': 'public-read',
          'Content-Type': mimetype.lookup(path)
        }
      },
      function(err, resp, body){
        if(err){
          promise.reject(err);
        }else if(resp.statusCode !== 200){
          promise.reject(body);
        }else{
          promise.resolve("File Uploaded.");
        }
      });
    }, function(err){
      promise.reject(err);
    });
}

function putObject(path, name, conn, promise){
    conn.call('uploadFile', name, mimetype.lookup(path)).then(function(url){
      try{
        var body = fs.readFileSync(path);
      }catch (e){
        promise.reject("Couldn't read file at specified path");
        return;
      }
      request.put({
        url: url,
        body: body,
        headers: {
          'x-amz-acl': 'public-read',
          'Content-Type': mimetype.lookup(path)
        }
      },
      function(err, resp, body){
        if(err){
          promise.reject(err);
        }else if(resp.statusCode !== 200){
          promise.reject(body);
        }else{
          promise.resolve("File Uploaded.");
        }
      });
    }, function(err){
      promise.reject(err);
    });
}
