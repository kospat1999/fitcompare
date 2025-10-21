<template>
  <div class="goals-container">
    <h3 class="form-section-title">🎯 Twoje cele</h3>

    <form @submit.prevent="saveGoals" class="goals-form">
      <div class="form-group">
        <label class="form-label">Czas treningu (min)</label>
        <input
          type="number"
          v-model.number="goals.training_time_goal"
          min="1"
          max="300"
          class="number-input-simple"
        />
      </div>

      <div class="form-group">
        <label class="form-label">Kalorie (max)</label>
        <input
          type="number"
          v-model.number="goals.calories_goal"
          min="500"
          max="5000"
          class="number-input-simple"
        />
      </div>

      <div class="form-group">
        <label class="form-label">Kroki (minimum)</label>
        <input
          type="number"
          v-model.number="goals.steps_goal"
          min="1000"
          max="50000"
          class="number-input-simple"
        />
      </div>

      <div class="form-group">
        <label class="form-label">Białko (minimum, g)</label>
        <input
          type="number"
          v-model.number="goals.protein_goal"
          min="10"
          max="300"
          step="0.1"
          class="number-input-simple"
        />
      </div>

      <button type="submit" class="action-btn">
        <span class="btn-icon">💾</span>
        Zapisz cele
      </button>
    </form>
  </div>
</template>

<script>
import { reactive, onMounted } from "vue";
import { supabase } from "../supabase.js";

export default {
  name: "GoalsForm",
  props: {
    userId: {
      type: Number,
      required: true,
    },
  },
  emits: ["goals-saved"],
  setup(props, { emit }) {
    const goals = reactive({
      training_time_goal: 60,
      calories_goal: 2000,
      steps_goal: 10000,
      protein_goal: 100.0,
    });

    const loadGoals = async () => {
      try {
        const { data, error } = await supabase
          .from("user_goals")
          .select("*")
          .eq("user_id", props.userId)
          .single();

        if (error && error.code !== "PGRST116") {
          throw error;
        }

        if (data) {
          Object.assign(goals, {
            training_time_goal: data.training_time_goal || 60,
            calories_goal: data.calories_goal || 2000,
            steps_goal: data.steps_goal || 10000,
            protein_goal: data.protein_goal || 100.0,
          });
        }
      } catch (error) {
        console.error("Error loading goals:", error);
      }
    };

    const saveGoals = async () => {
      try {
        const { error } = await supabase.from("user_goals").upsert(
          {
            user_id: props.userId,
            training_time_goal: goals.training_time_goal,
            calories_goal: goals.calories_goal,
            steps_goal: goals.steps_goal,
            protein_goal: goals.protein_goal,
            supplements_goal: true, // Zawsze true
            updated_at: new Date().toISOString(),
          },
          {
            onConflict: "user_id",
            ignoreDuplicates: false,
          }
        );

        if (error) throw error;

        emit("goals-saved", {
          ...goals,
          supplements_goal: true, // Zawsze true
        });
      } catch (error) {
        console.error("Error saving goals:", error);
      }
    };

    onMounted(() => {
      loadGoals();
    });

    return {
      goals,
      saveGoals,
    };
  },
};
</script>

<style scoped>
.goals-container {
  background: #2c2c2c;
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 20px;
}

.form-section-title {
  color: #fff;
  font-size: 20px;
  font-weight: 600;
  margin-bottom: 20px;
  font-family: "Poppins", sans-serif;
}

.goals-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-label {
  color: #fff;
  font-size: 14px;
  font-weight: 500;
  font-family: "Poppins", sans-serif;
}

.number-input-simple {
  padding: 12px 16px;
  background: #1a1a1a;
  border: 1px solid #333;
  border-radius: 8px;
  color: #fff;
  font-size: 16px;
  font-family: "Poppins", sans-serif;
  transition: border-color 0.2s;
}

.number-input-simple:focus {
  outline: none;
  border-color: #00c073;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
}

.checkbox-input {
  width: 18px;
  height: 18px;
  accent-color: #00c073;
}

.checkbox-text {
  color: #fff;
  font-size: 14px;
  font-family: "Poppins", sans-serif;
}

.action-btn {
  padding: 14px 20px;
  background: linear-gradient(135deg, #00c073, #00a060);
  border: none;
  border-radius: 8px;
  color: #fff;
  font-size: 16px;
  font-weight: 500;
  font-family: "Poppins", sans-serif;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(255, 127, 39, 0.3);
}

.action-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(255, 127, 39, 0.4);
}

.btn-icon {
  font-size: 18px;
}
</style>
