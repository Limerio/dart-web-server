// Authentication utility functions

// Check if user is logged in
function isLoggedIn() {
  return localStorage.getItem("authToken") !== null;
}

// Save authentication token
function setAuthToken(token) {
  localStorage.setItem("authToken", token);
}

// Get the authentication token
function getAuthToken() {
  return localStorage.getItem("authToken");
}

// Remove authentication token (logout)
function logout() {
  localStorage.removeItem("authToken");
  window.location.href = "/login.html";
}

// Redirect to login page if not authenticated
function requireAuth() {
  if (!isLoggedIn()) {
    window.location.href =
      "/login.html?redirect=" + encodeURIComponent(window.location.pathname);
    return false;
  }
  return true;
}

// Redirect to home page if already authenticated
function redirectIfAuthenticated() {
  if (isLoggedIn()) {
    window.location.href = "/";
    return true;
  }
  return false;
}
