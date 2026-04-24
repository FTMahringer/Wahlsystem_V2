import axios from "axios";

const authStorage = sessionStorage;

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || "http://localhost:8080/api/v1",
  headers: {
    "Content-Type": "application/json",
  },
  timeout: 10000,
});

// Request interceptor
apiClient.interceptors.request.use(
  (config) => {
    const token = authStorage.getItem("auth_token");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  },
);

// Response interceptor
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Handle unauthorized - clear token and redirect to login
      authStorage.removeItem("auth_token");
      authStorage.removeItem("refresh_token");
      authStorage.removeItem("user");

      // Only redirect if not already on login page
      const currentPath = window.location.pathname;
      if (!currentPath.includes("/login")) {
        window.location.href = "/login";
      }
    }

    // Enhance error with user-friendly message
    if (error.response?.data?.message) {
      error.userMessage = error.response.data.message;
    } else if (error.response?.status === 403) {
      error.userMessage =
        "Zugriff verweigert. Sie haben nicht die erforderlichen Berechtigungen für diese Aktion.";
    } else if (error.response?.status === 404) {
      error.userMessage = "Die angeforderte Ressource wurde nicht gefunden.";
    } else if (error.response?.status === 409) {
      error.userMessage =
        "Die Aktion konnte nicht ausgeführt werden, da ein Konflikt besteht.";
    } else if (error.response?.status === 422) {
      error.userMessage =
        "Die übermittelten Daten sind ungültig. Bitte überprüfen Sie Ihre Eingaben.";
    } else if (error.response?.status === 429) {
      error.userMessage =
        "Zu viele Anfragen. Bitte warten Sie einen Moment und versuchen Sie es erneut.";
    } else if (error.response?.status >= 500) {
      error.userMessage =
        "Ein Serverfehler ist aufgetreten. Bitte versuchen Sie es später erneut.";
    } else if (!error.response) {
      error.userMessage =
        "Keine Verbindung zum Server. Bitte überprüfen Sie Ihre Internetverbindung.";
    } else {
      error.userMessage = "Ein unerwarteter Fehler ist aufgetreten.";
    }

    return Promise.reject(error);
  },
);

export default apiClient;
