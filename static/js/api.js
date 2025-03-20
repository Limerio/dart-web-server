// API utility functions for the application

// Base API URL
const API_BASE_URL = "/api";

// Generic fetch function with error handling
async function fetchAPI(endpoint, options = {}) {
  try {
    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      ...options,
      headers: {
        "Content-Type": "application/json",
        ...options.headers,
      },
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(
        errorData.message || `Request failed with status ${response.status}`
      );
    }

    return await response.json();
  } catch (error) {
    console.error("API request failed:", error);
    throw error;
  }
}

// User-related API functions
const UserAPI = {
  login: async (email, password) => {
    return await fetchAPI("/users/login", {
      method: "POST",
      body: JSON.stringify({ email, password }),
    });
  },

  register: async (userData) => {
    return await fetchAPI("/users/register", {
      method: "POST",
      body: JSON.stringify(userData),
    });
  },

  getProfile: async () => {
    const token = localStorage.getItem("authToken");
    return await fetchAPI("/users/profile", {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });
  },

  updateProfile: async (userData) => {
    const token = localStorage.getItem("authToken");
    return await fetchAPI("/users/profile", {
      method: "PUT",
      headers: {
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(userData),
    });
  },
};

// Book-related API functions
const BookAPI = {
  getAllBooks: async () => {
    return await fetchAPI("/books");
  },

  getBooksByCategory: async (categoryId) => {
    return await fetchAPI(`/books?category_id=${categoryId}`);
  },

  getAllBooks: async () => {
    return await fetchAPI("/books");
  },

  getBookById: async (id) => {
    return await fetchAPI(`/books/${id}`);
  },

  searchBooks: async (query) => {
    return await fetchAPI(`/books/search?q=${encodeURIComponent(query)}`);
  },

  addBook: async (bookData) => {
    const token = localStorage.getItem("authToken");
    return await fetchAPI("/books", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(bookData),
    });
  },

  updateBook: async (id, bookData) => {
    const token = localStorage.getItem("authToken");
    return await fetchAPI(`/books/${id}`, {
      method: "PUT",
      headers: {
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(bookData),
    });
  },

  deleteBook: async (id) => {
    const token = localStorage.getItem("authToken");
    return await fetchAPI(`/books/${id}`, {
      method: "DELETE",
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });
  },
};

const CategoryAPI = {
  getAllCategories: () => fetchAPI("/categories"),

  getCategoryById: async (id) => {
    return await fetchAPI(`/categories/${id}`);
  },

  getBooksByCategory: async (id) => {
    return await fetchAPI(`/categories/${id}/books`);
  },

  addCategory: (categoryData) => {
    const token = localStorage.getItem("authToken");
    return fetchAPI("/categories", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(categoryData),
    });
  },

  updateCategory: async (id, categoryData) => {
    const token = localStorage.getItem("authToken");
    return await fetchAPI(`/categories/${id}`, {
      method: "PUT",
      headers: {
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(categoryData),
    });
  },

  deleteCategory: async (id) => {
    const token = localStorage.getItem("authToken");
    return await fetchAPI(`/categories/${id}`, {
      method: "DELETE",
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });
  },
};
