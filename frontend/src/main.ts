import { createApp } from "vue";
import { createPinia } from "pinia";
import router from "./router";
import App from "./App.vue";
import { useUiStore } from "@/stores/uiStore";

const app = createApp(App);
const pinia = createPinia();

app.use(pinia);
app.use(router);

useUiStore(pinia).initializePreferences();

app.mount("#app");
