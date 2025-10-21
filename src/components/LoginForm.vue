<template>
  <div class="login-container">
    <div class="login-card">
      <h1 class="app-title">FitCompare</h1>

      <form @submit.prevent="handleLogin" class="login-form">
        <input
          type="text"
          v-model="username"
          class="login-input"
          placeholder="Login"
          required
        />

        <input
          type="password"
          v-model="password"
          class="login-input"
          placeholder="Hasło"
          required
        />

        <button type="submit" class="login-btn" :disabled="loading">
          {{ loading ? "Logowanie..." : "Zaloguj się" }}
        </button>

        <div v-if="error" class="error">
          {{ error }}
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import { ref } from "vue";
import { supabase } from "../supabase.js";

export default {
  name: "LoginForm",
  emits: ["login-success"],
  setup(props, { emit }) {
    const username = ref("");
    const password = ref("");
    const loading = ref(false);
    const error = ref("");

    const handleLogin = async () => {
      loading.value = true;
      error.value = "";

      try {
        // Sprawdź dane logowania
        const { data, error: loginError } = await supabase
          .from("users")
          .select("*")
          .eq("username", username.value)
          .eq("password", password.value)
          .single();

        if (loginError) {
          throw loginError;
        }

        if (data) {
          // Zapisz dane użytkownika w localStorage
          localStorage.setItem("fitcompare-user", JSON.stringify(data));
          emit("login-success", data);
        } else {
          error.value = "Nieprawidłowy login lub hasło";
        }
      } catch (err) {
        console.error("Login error:", err);
        error.value = "Nieprawidłowy login lub hasło";
      } finally {
        loading.value = false;
      }
    };

    return {
      username,
      password,
      loading,
      error,
      handleLogin,
    };
  },
};
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #0a0a0a;
  padding: 20px;
}

.login-card {
  background: #1a1a1a;
  border: 1px solid #333;
  border-radius: 8px;
  padding: 40px;
  width: 100%;
  max-width: 480px;
}

.app-title {
  color: #fff;
  font-size: 36px;
  font-weight: 600;
  text-align: center;
  margin: 0 0 40px 0;
  letter-spacing: -0.5px;
  font-family: "Poppins", sans-serif;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.login-input {
  padding: 18px 24px;
  background: #0a0a0a;
  border: 1px solid #333;
  border-radius: 8px;
  color: #fff;
  font-size: 16px;
  font-family: "Poppins", sans-serif;
  font-weight: 400;
  transition: border-color 0.2s;
  width: 100%;
}

.login-input:focus {
  outline: none;
  border-color: #00c073;
}

.login-input::placeholder {
  color: #666;
}

.login-btn {
  padding: 18px 24px;
  background: #00c073;
  border: none;
  border-radius: 8px;
  color: #fff;
  font-size: 16px;
  font-weight: 500;
  font-family: "Poppins", sans-serif;
  cursor: pointer;
  transition: background-color 0.2s;
  margin-top: 8px;
}

.login-btn:hover:not(:disabled) {
  background: #00a060;
}

.login-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.error {
  background: #ff4444;
  color: #fff;
  padding: 16px;
  border-radius: 8px;
  text-align: center;
  font-size: 14px;
  font-family: "Poppins", sans-serif;
  font-weight: 400;
}
</style>
