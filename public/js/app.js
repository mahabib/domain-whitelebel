console.log("app.js loaded");

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
        alert("New Organization Added Successfully");
        location.reload();
      } else {
        var rt = this.responseText;
        console.log(rt);
      }
    }
  }

  xhttp.open("POST", "/orgs", true);
  xhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
  xhttp.send(JSON.stringify(vals));
}

function createUser(el) {
  if (!window.XMLHttpRequest) { alert("Sorry, This browser doesn't have support for XMLHttpRequest"); }

  var name = document.getElementById('name');
  var email = document.getElementById('email');
  var gender = document.getElementById('gender');
  var contact_no = document.getElementById('contact_no');
  var address = document.getElementById('address');
  var vals = {
    'name': name.value,
    'email': email.value,
    'gender': gender.value,
    'contact_no': contact_no.value,
    'address': address.value
  }
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4) {
      if (this.status == 200) {
        alert("New User Added Successfully");
        location.reload();
      } else {
        var rt = this.responseText;
        console.log(rt);
      }
    }
  }

  xhttp.open("POST", "/users", true);
  xhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
  xhttp.send(JSON.stringify(vals));
}
