console.log("app.js loaded");
var csrfToken = document.head.querySelector('meta[name="csrf-token"]');

document.addEventListener('DOMContentLoaded', function() {
  var modalOptions = {};
  var modalElems = document.querySelectorAll('.modal');
  var modalInstances = M.Modal.init(modalElems, modalOptions);

  var selectOptions = {};
  var selectElems = document.querySelectorAll('select');
  var selectInstances = M.FormSelect.init(selectElems, selectOptions);
});

function createOrg(el) {
  if (!window.XMLHttpRequest) { alert("Sorry, This browser doesn't have support for XMLHttpRequest"); }

  var modal = M.Modal.getInstance(document.getElementById('createOrgModal'));
  var name = document.getElementById('name');
  var description = document.getElementById('description');
  var vals = {
    'name': name.value,
    'description': description.value
  }
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4) {
      if (this.status == 200) {
        modal.close();
        alert("New Organization Added Successfully");
        location.reload();
      } else {
        alert(this.responseText);
      }
    }
  }

  xhttp.open("POST", "/orgs", true);
  xhttp.setRequestHeader("content-type", "application/json");
  xhttp.setRequestHeader("X-CSRF-TOKEN", csrfToken.content);
  xhttp.setRequestHeader("Authorization", "Bearer  +localStorage.getItem('idToken')"+localStorage.getItem('idToken'));
  xhttp.send(JSON.stringify(vals));
}

function updateOrg(el, subdomain) {
  if (!window.XMLHttpRequest) { alert("Sorry, This browser doesn't have support for XMLHttpRequest"); }

  var modal = M.Modal.getInstance(document.getElementById('updateOrgModal'));
  var name = document.getElementById('name');
  var description = document.getElementById('description');
  var vals = {
    'name': name.value,
    'description': description.value
  }
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4) {
      if (this.status == 200) {
        modal.close();
        alert("Organization updated Successfully");
        location.reload();
      } else {
        alert(this.responseText);
      }
    }
  }

  xhttp.open("PUT", "/orgs/"+subdomain, true);
  xhttp.setRequestHeader("Content-Type", "application/json");
  xhttp.setRequestHeader("X-CSRF-TOKEN", csrfToken.content);
  xhttp.setRequestHeader("Authorization", "Bearer  +localStorage.getItem('idToken')"+localStorage.getItem('idToken'));
  xhttp.send(JSON.stringify(vals));
}

function createOrgUser(el, subdomain) {
  if (!window.XMLHttpRequest) { alert("Sorry, This browser doesn't have support for XMLHttpRequest"); }

  var modal = M.Modal.getInstance(document.getElementById('createOrgUserModal'));
  var email = document.getElementById('email');
  var vals = {
    'email': email.value
  }
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4) {
      if (this.status == 200) {
        modal.close();
        alert("A User Added Successfully");
        location.reload();
      } else {
        alert(this.responseText);
      }
    }
  }

  xhttp.open("POST", "/orgs/"+subdomain+"/users", true);
  xhttp.setRequestHeader("Content-Type", "application/json");
  xhttp.setRequestHeader("X-CSRF-TOKEN", csrfToken.content);
  xhttp.setRequestHeader("Authorization", "Bearer  +localStorage.getItem('idToken')"+localStorage.getItem('idToken'));
  xhttp.send(JSON.stringify(vals));
}

function register(el) {
  if (!window.XMLHttpRequest) { alert("Sorry, This browser doesn't have support for XMLHttpRequest"); }

  var name = document.getElementById('name');
  var email = document.getElementById('email');
  var gender = document.getElementById('gender');
  var contact_no = document.getElementById('contact_no');
  var address = document.getElementById('address');
  var password = document.getElementById('password');
  
  var vals = {
    'name': name.value,
    'email': email.value,
    'gender': gender.value,
    'contact_no': contact_no.value,
    'address': address.value,
    'password': password.value
  }
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4) {
      if (this.status == 200) {
        fetch('/login', {
          method: 'post',
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-TOKEN": csrfToken.content
          },
          body: JSON.stringify({'email': email.value, 'password': password.value})
        })
        .then(fetchHandleResponse)
        .then(function(resp) {
          localStorage.setItem('idToken', resp.values.token);
          location = '/';
        })
        .catch(function(error) {
          alert(error.err);
        });
      } else {
        var rt = this.responseText;
        console.log(rt);
      }
    }
  }

  xhttp.open("POST", "/register", true);
  xhttp.setRequestHeader("content-type", "application/json");
  xhttp.setRequestHeader("X-CSRF-TOKEN", csrfToken.content);
  xhttp.send(JSON.stringify(vals));
}

function fetchHandleResponse (response) {
  let contentType = response.headers.get('content-type')
  if (contentType.includes('application/json')) {
    return fetchHandleJSONResponse(response);
  } else if (contentType.includes('text/html')) {
    return fetchHandleTextResponse(response);
  } else {
    throw new Error(`Sorry, content-type ${contentType} not supported`);
  }
}

function fetchHandleJSONResponse (response) {
  return response.json()
    .then(function(json) {
      if (response.ok) {
        return json;
      } else {
        return Promise.reject(Object.assign({}, json, {
          status: response.status,
          statusText: response.statusText
        }));
      }
    });
}

function fetchHandleTextResponse (response) {
  return response.text()
    .then(function(text) {
      if (response.ok) {
        return json;
      } else {
        return Promise.reject({
          status: response.status,
          statusText: response.statusText,
          err: text
        });
      }
    });
}

function login(el) {
  var email = document.getElementById('email');
  var password = document.getElementById('password');
  
  var vals = {
    'email': email.value,
    'password': password.value
  }

  fetch('/login', {
    method: 'post',
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-TOKEN": csrfToken.content
    },
    body: JSON.stringify(vals)
  })
  .then(fetchHandleResponse)
  .then(function(resp) {
    localStorage.setItem('idToken', resp.values.token);
    location = '/';
  })
  .catch(function(error) {
    // console.log('Request failed', error);
    alert(error.err);
  });

  // $.ajax({
  //   type: 'POST',
  //   url: '/login',
  //   data: JSON.stringify(vals),
  //   contentType: 'application/json',
  //   headers: {
  //     "X-CSRF-TOKEN": csrfToken.content
  //   },
  //   error: function(xhr) {
  //     console.log(xhr);
  //   },
  //   success: function(res) {
  //     console.log(res);
  //   }
  // });
}

function logout(el) {
  fetch('/logout', {
    method: 'post',
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-TOKEN": csrfToken.content
    }
  })
  .then(fetchHandleResponse)
  .then(function(resp) {
    localStorage.removeItem('idToken');
    location = '/login';
  })
  .catch(function(error) {
    alert(error.err);
  });
}
